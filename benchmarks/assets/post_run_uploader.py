import json
import csv
import os
import platform
import argparse
from pymongo import MongoClient
from datetime import datetime

# check for vaild file path
def is_valid_path(parser, arg):
    if not os.path.isdir(arg):
        parser.error("The path %s does not exist!" % arg)
    else:
        return arg  # return the arg


# check for valid provided file
def is_valid_file(parser, arg):
    if not os.path.isfile(arg):
        parser.error("The file %s does not exist!" % arg)
    else:
        return open(arg, 'r')  # return open file handle


# make connection to mongodb
def connect_to_perf_test(custom_connection):
    connection_string = custom_connection.readline()
    client = MongoClient(connection_string)
    return client.perf_test


# build the test results doc
def build_test_results():
    test_result_doc = {'run_date': datetime.utcnow()}
    return test_result_doc


# read in the timing_csv file to grab time_secs data
def read_timing_csv(timing_file):
    with open(timing_file, 'r') as csv_file:
        csv_reader = csv.DictReader(csv_file)
        data = {row[0]: {'time_sec': row[1], 'mflops': row[2], 'flop': row[3]} for row in csv_reader.reader}
        data.pop('Timer', None)
    return {'timing_csv': data}


def remove_dots(d):
    if type(d) is dict:
        for key, value in d.items():
            d[key] = remove_dots(value)
            if '.' in key:
                d[key.replace('.', '[dot]')] = value
                del(d[key])
    return d    
    

# read in the pf_metadata file to import data
def read_pf_metadata_file(metadata_file):
    with open(metadata_file, 'r', encoding='utf-8') as f:
        data = json.load(f, object_hook=remove_dots)
        return {'pfmetadata': data}


# insert the finished doc into Mongo
def insert_test_result_doc(db_collection, test_doc):
    # per https://docs.mongodb.com/manual/reference/limits/#Restrictions-on-Field-Names
    # use check_keys=False to support . in field names, however, isn't implemented in insert_one
    db_collection.insert_one(test_doc)

def build_sys_info_dict():
    return {"run_information": {
                "run_specifications":{
                    "domain": "",
                    "test_start_time": "",
                    "solver_config": "",
                    "test_results": "",
                    "timesteps": "",
                    "processor_topology": ""
                },
                "system_information": {
                    "hostname": platform.node(),
                    "system_specifications": {
                        "arch": "",
                        "byte_order": "",
                        "cores": "",
                        "threads": "",
                        "sockets": "",
                        "cpu_family": "",
                        "vendor_id": "",
                        "total_memory_KB": ""
                    }
                }
            }}

def parse_specs_linux(run_info):
    #run lscpu and collect information
    stream = os.popen('lscpu')
    lscpu_output = str(stream.read())
    lscpu_list = lscpu_output.split('\n')

    #ease of referencing later
    sys_spec_dict = run_info["run_information"]["system_information"]["system_specifications"]

    #iterate through lscpu and get relevant info
    for specification in range(len(lscpu_list) - 1):
        #Do some easy string ops to get clean output
        spec_list = lscpu_list[specification].split(':')
        spec_list[1] = spec_list[1].lstrip(' ')

        #for less chars later
        category = spec_list[0]
        spec = spec_list[1] 

        #check for all arguments we want
        if category == "Architecture":
            sys_spec_dict["arch"] = spec
        if category == "Byte Order":
            sys_spec_dict["byte_order"] = spec
        if category == "CPU(s)":
            sys_spec_dict["threads"] = spec
        if category == "Thread(s) per core":
            sys_spec_dict["cores"] = str(int(int(sys_spec_dict["threads"])/int(spec)))
        if category == "CPU family":
            sys_spec_dict["cpu_family"] = spec
        if category == "Model name":
            sys_spec_dict["model_name"] = spec
        if category == "Socket(s)":
            sys_spec_dict["sockets"] = spec
        if category == "Vendor ID":
            sys_spec_dict["vendor_id"] = spec

    #calculate memory size
    mem_bytes = os.sysconf('SC_PAGE_SIZE') * os.sysconf('SC_PHYS_PAGES')
    sys_spec_dict["total_memory_KB"] = int(mem_bytes/(1024.))

def read_and_parse_log(abs_paths_doc, run_info):
    #get test_case.log info

    #parse test_case.log for start time and processor topology
    with open(abs_paths_doc['test_case.log']) as fp:
        currLine = fp.readline()
        while "MachineName" not in currLine:
            #check for elements i'm looking for
            if "Test Started" in currLine:
                #do some manipulations to get clean data
                temp_string_list = currLine.split(':', 1)
                temp_string_list[1] = temp_string_list[1].lstrip(' ')
                temp_string_list[1] = temp_string_list[1].strip()
                run_info["run_information"]["run_specifications"]["test_start_time"] = temp_string_list[1].strip('\n')
            if "Test Configuration" in currLine:
                #do some manipulations to get clean data
                temp_string_list = currLine.split(':')
                temp_string_list[1] = temp_string_list[1].lstrip(' ')
                run_info["run_information"]["run_specifications"]["processor_topology"] = temp_string_list[1].strip('\n ')
            currLine = fp.readline()

    #get validation results
    with open(abs_paths_doc['validation.log']) as fp:
        lines = fp.readlines()
        domain = run_info["run_information"]["run_specifications"]["domain"]
        #iterate through all the lines looking for the final passed or failed
        for line in lines:
            if f"{domain} : PASSED" in line:
                run_info["run_information"]["run_specifications"]["test_results"] = "PASSED"
            if f"{domain} : FAILED" in line:
                run_info["run_information"]["run_specifications"]["test_results"] = "FAILED"

def build_paths_doc(solver_config_path, run_info):
    paths_doc = {
        'test_case.log': "",
        'validation.log': "",
        'pfmetadata': "",
        'timing_csv': "",
    }

    domainName = None
    solverConfig = os.path.basename(solver_config_path)

    for root, dirs, files in os.walk(solver_config_path):
        for mfile in files:
            if ".out.pfmetadata" in mfile:
                paths_doc['pfmetadata'] = os.path.join(root, mfile)
                domainName = mfile.split(".")[0]
            if "test_case.log" in mfile:
                paths_doc['test_case.log'] = os.path.join(root, mfile)
            if ".out.timing.csv" in mfile:
                paths_doc['timing_csv'] = os.path.join(root, mfile)
            if "validation.log" in mfile:
                paths_doc['validation.log'] = os.path.join(root, mfile)

    for doc in paths_doc:
        if paths_doc[doc] == "":
            print("File not found: " + doc)

    run_info['run_information']['run_specifications']['domain'] = domainName
    run_info['run_information']['run_specifications']['solver_config'] = solverConfig

    return paths_doc

# Parse the commandline args
def parse_args():
    parser = argparse.ArgumentParser(description='Submit documents to the Hydroframe MongoDB')
    parser.add_argument("--solverconfig", "-s", dest="solverconfig", required=True,
                        help="The solver config used on the current Parflow run")
    parser.add_argument("--mongostring", "-m", dest="mongostring", required=True,
                        type=lambda x: is_valid_file(parser, x),
                        help="The exact path of a txt file containing cusotom mongo connection string")
    return parser.parse_args()


# main
def main():
    # parse commandline args
    args = parse_args()

    # connect to the database
    hydroDB = connect_to_perf_test(args.mongostring)

    # change to test_results db
    test_results = hydroDB.test_results

    # build dictionary of system specifications
    run_info =  build_sys_info_dict()

    #pull system specs
    if(platform.system() == "Linux"):
        parse_specs_linux(run_info)
    
    #build absolute paths doc for direct access
    abs_paths_doc = build_paths_doc(args.solverconfig, run_info)

    #pull run_information
    read_and_parse_log(abs_paths_doc, run_info)

    # Pull in output files from parflow
    test_doc = read_pf_metadata_file(abs_paths_doc['pfmetadata'])
    csv_doc = read_timing_csv(abs_paths_doc['timing_csv'])

    #get timesteps
    timestepStart = test_doc['pfmetadata']['inputs']['configuration']['data']['TimingInfo[dot]StartTime']
    timestepStop = test_doc['pfmetadata']['inputs']['configuration']['data']['TimingInfo[dot]StopTime']
    timestepUnit = test_doc['pfmetadata']['inputs']['configuration']['data']['TimeStep[dot]Value']
    timesteps = float((float(timestepStop) - float(timestepStart)) / float(timestepUnit))

    #set timesteps
    run_info["run_information"]["run_specifications"]["timesteps"] = timesteps


    # append docs to doc to be inserted
    test_result_doc = build_test_results()
    test_result_doc.update(csv_doc)
    test_result_doc.update(test_doc)
    test_result_doc.update(run_info)

    # insert into db
    insert_test_result_doc(test_results, test_result_doc)


if __name__ == '__main__':
    main()
