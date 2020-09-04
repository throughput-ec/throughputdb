from re import search
import json


def goodHit(query, text):
    """Check for expected query call in file content.

    Parameters
    ----------
    query : str
        Text string passed to the original GitHub code search query.
    text : list
        The File contents, including highlighted fragments.

    Returns
    -------
    type
        Description of returned object.

    """

    strings = query.split(" ")
    matchlib = ".*" + strings[0] + r'\(([^\)]*' + strings[1] + ')'
    matchcal = strings[1] + r'\:\:'
    matchvig = r".*VignetteDepends\{([^\}])*" + strings[1]
    checklib = list(map(lambda x: search(matchlib, x.get('fragment')), text))
    checkcal = list(map(lambda x: search(matchcal, x.get('fragment')), text))
    checkvig = list(map(lambda x: search(matchvig, x.get('fragment')), text))
    check = checkcal + checklib + checkvig
    output = not(all(matches is None for matches in check))
    if output is not True:
        f = open("fail_log.txt", "a")
        textdump = {'query': query,
                    'text': list(map(lambda x: x.get('fragment'), text))}
        f.write(json.dumps(textdump) + "\n")
        f.close()
    else:
        f = open("pass_log.txt", "a")
        textdump = {'query': query,
                    'text': list(map(lambda x: x.get('fragment'), text))}
        f.write(json.dumps(textdump) + "\n")
        f.close()
    return output
