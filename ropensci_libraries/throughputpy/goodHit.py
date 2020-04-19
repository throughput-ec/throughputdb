from re import match


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
    matcher = strings[0] + r'\(([^\)]*' + strings[1] + ')'
    check = list(map(lambda x: match(matcher, x.get('fragment')), text))
    output = not(all(matches is None for matches in check))
    return output
