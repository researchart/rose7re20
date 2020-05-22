#!/usr/bin/env python3

import datetime, json, logging, openpyxl, os.path, sys, urllib.request

class aggregators:
    @staticmethod
    def layout(data):
        out = []
        last_to = None
        for d in data:
            if last_to == None:
                out.append(d['from'])
            elif last_to != d['from']:
                out.append( '|_' + d['from'])
            out.append(d['to'])
            last_to = d['to']
        return out

    @staticmethod
    def shorten(data):
        return (''.join(part[0] for part in d.split('_') if not part.isdigit() and not part == "CODE") for d in data)

    @staticmethod
    def unique(data):
        return set(data)

    @staticmethod
    def avg(data):
        data = list(data)
        return sum(data) / len(data)

    @staticmethod
    def round(data, ndigits = "2"):
        return ( round(d, int(ndigits)) for d in data )

    @staticmethod
    def last(data):
        return ( d.rpartition('.')[2] for d in data )

    @staticmethod
    def max(data):
        return max(data)

    @staticmethod
    def min(data):
        return min(data)

    @staticmethod
    def join(data, sep = ''):
        return sep.join(data)

    @staticmethod
    def log_and(data):
        return 'x' if all(data) else ''

    @staticmethod
    def log_or(data):
        return 'x' if any(data) else ''

    @staticmethod
    def single(data):
        data = list(data)
        assert len(data) == 1
        return data[0]

def get_value(data, path):
    if not path:
        return data

    p, _, path = path.partition('/')
    p, _, aggs = p.partition('#')

    data = data[p]
    if aggs:
        for agg in aggs.split('#'):
            agg, argsep, args = agg.partition('!')
            args = args.split('!') if argsep else []

            if isinstance(data, str) or not hasattr(data, '__iter__' ):
                data = next(getattr(aggregators, agg)( [ get_value(data, path) ], *args))
            else:
                data = getattr(aggregators, agg)( (get_value(d, path) for d in data), *args)
            path = ''
        return data

    return get_value(data, path)

def main():
    wb = openpyxl.load_workbook(sys.argv[1])
    ws = wb['Data']

    cols = [ ws.cell(1, col).value for col in range(1, ws.max_column + 1) ]

    for row_idx in range(2, ws.max_row + 1):
        task_id = int(ws.cell(row_idx, 1).value)
        url = 'http://localhost:8888/tasks?printresult=true&id=' + str(task_id)

        try:
            with urllib.request.urlopen(url) as f:
                data = json.load(f)
                for col_idx, col in enumerate(cols):
                    if col:
                        try:
                            val = get_value(data, col)
                            ws.cell(row_idx, col_idx + 1).value = val
                        except:
                            logging.exception('Failed parsing column ' + str(col))
        except:
            logging.exception('Failed loading task ' + str(task_id))

    outfile = sys.argv[1]
    #directory, filename = os.path.split(sys.argv[1])
    #filename, ext = os.path.splitext(filename)
    #outfile = filename + '.' + datetime.datetime.now().replace(microsecond = 0).isoformat() + ext

    wb.save(outfile)
    os.system("xdg-open '" + outfile + "'")


if __name__ == "__main__":
    main()
