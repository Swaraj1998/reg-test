#!/usr/bin/env python3

# Copyright (C) 2021 Swaraj Hota

import os
import json

## Set the correct paths to prjxray
DB_PATH = 'database/zynq7/'
TILE_GRID_JSON = 'database/zynq7/xc7z020s/tilegrid.json'

OUTPUT_JSON = 'slice_lut_db.json'

if __name__ == "__main__":

    with open(TILE_GRID_JSON) as f:
        tgrid = json.load(f)

    print('Parsing data...')

    db = dict()
    for tile in tgrid:
        if tile[:3] == 'CLB':
            for (sii, site) in enumerate(tgrid[tile]['sites']):
                bus_info = tgrid[tile]['bits']['CLB_IO_CLK'] 
                db[site] = {
                    'tile': tile,
                    'baseaddr': bus_info['baseaddr'],
                    'offset': bus_info['offset'],
                    'alut': { 'init' : [], 'frames' : [] }, 
                    'blut': { 'init' : [], 'frames' : [] }, 
                    'clut': { 'init' : [], 'frames' : [] }, 
                    'dlut': { 'init' : [], 'frames' : [] } 
                }

                seg_db_name = 'segbits_' + tile[:7].lower() + '.db'
                with open(DB_PATH + seg_db_name, 'r') as f:
                    while True:
                        row = f.readline().split()
                        if len(row) == 0:
                            break
                        feat = row[0].split('.')
                        if len(feat) >= 4 and feat[3][:-3] == 'INIT[':
                            if feat[1] == tgrid[tile]['sites'][site] + '_X' + str(sii):
                                lut = feat[2]
                                db[site][lut.lower()]['init'].append(row[1])
                                fr, bit = row[1].split('_')
                                fr = int(fr)
                                if fr not in db[site][lut.lower()]['frames']:
                                    db[site][lut.lower()]['frames'].append(fr)
                            
    print('Writing data to ' + OUTPUT_JSON + '...')
    # print(db) 
    with open(OUTPUT_JSON, 'w') as f:
        # json.dump(db, f, indent = 4)
        json.dump(db, f)

    print('Done')
