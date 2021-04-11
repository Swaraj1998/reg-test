import sys
import json

DB_JSON = 'slice_lut_db.json'

if __name__ == "__main__":
    assert len(sys.argv) == 2

    slc, lut = sys.argv[1].split('/')

    with open(DB_JSON) as f:
        db = json.load(f)
    
    sliceinfo = db[slc]
    if lut == 'A6LUT':
        lutframes = sliceinfo['alut']['frames']
    elif lut == 'B6LUT':
        lutframes = sliceinfo['blut']['frames']
    elif lut == 'C6LUT':
        lutframes = sliceinfo['clut']['frames']
    elif lut == 'D6LUT':
        lutframes = sliceinfo['dlut']['frames']
    else:
        print('Unrecognized LUT: ' + lut)
        exit(1)

    # print('Frame addresses for location ' + sys.argv[1] + ': ')
    for fr in lutframes:
        print('0x{:08x}'.format(int(sliceinfo['baseaddr'], 16) + fr))

    
