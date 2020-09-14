import json
import csv
import os
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
def build_test_results(runname):
    test_result_doc = {'run_date': datetime.utcnow()}
    test_result_doc.update({'runname': runname})
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


# Parse the commandline args
def parse_args():
    parser = argparse.ArgumentParser(description='Submit documents to the Hydroframe MongoDB')
    parser.add_argument("--path", "-p", dest="input_path", required=True,
                        type=lambda x: is_valid_path(parser, x),
                        help="The directory containing runname.out.pfmetadata and LW.out.timing.csv")
    parser.add_argument("--runname", "-r", dest="runname", required=True,
                        help="The runname of the ParFlow model run")
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

    # Pull in output files from parflow
    test_doc = read_pf_metadata_file(os.path.join(args.input_path, f"{args.runname}.out.pfmetadata"))
    csv_doc = read_timing_csv(os.path.join(args.input_path, f"{args.runname}.out.timing.csv"))

    # append docs to doc to be inserted
    test_result_doc = build_test_results(runname=args.runname)
    test_result_doc.update(csv_doc)
    test_result_doc.update(test_doc)

    # insert into db
    insert_test_result_doc(test_results, test_result_doc)


if __name__ == '__main__':
    main()
