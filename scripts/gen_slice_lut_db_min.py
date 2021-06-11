#!/usr/bin/env python3

# Copyright (C) 2021 Swaraj Hota

import json

REG_SLICE_DB = '../build/reg_slice_map.db'

MASTER_DB_JSON = 'slice_lut_db.json'
OUTPUT_JSON = '../build/slice_lut_db_min.json'

if __name__ == "__main__":

    with open(MASTER_DB_JSON) as f:
        slc_lut_db = json.load(f)

    out_db = dict()
    with open(REG_SLICE_DB, 'r') as f:
        line = f.readline()
        while line:
            entry = line.strip().split(' ')
            for loc in entry[1:]:
                slc, lut = loc.split('/')
                if slc not in out_db:
                    out_db[slc] = slc_lut_db[slc]
            line = f.readline()

    with open(OUTPUT_JSON, 'w') as f:
        json.dump(out_db, f)
