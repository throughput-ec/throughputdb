import time
from github import RateLimitExceededException
from throughputpy import goodHit
from json import dumps


def callquery(g, query, silent=False):
    """Calls the GitHub API through the GitHub package.
    Probably better to pass the `g` object as well.

    Parameters
    ----------
    g : Github
        The GitHub session connection.
    query : string
        A query to pass to the GitHub code search API at
        https://developer.github.com/v3/search/
    silent : boolean
        Should a verbose response be returned?

    Returns
    -------
    set
        The set of all responses from the code search as a JSON string with
        keys `id`, `name`, `url`, `description` and `keywords`.

    """
    resset = set()
    left = g.get_rate_limit()
    if left.search.remaining < 5:
        reset = left.search.reset
        diff = int(reset.strftime('%s')) - int(time.mktime(time.gmtime()))
        if diff > 0:
            print('pausing . . for ' + str(diff) + 'sec')
            time.pause(diff)
    while True:
        try:
            results = g.search_code(query, highlight=True)
            break
        except RateLimitExceededException:
            delay = g.rate_limiting_resettime
            diff = delay - int(time.mktime(time.gmtime()))
            print("Hit error.  Waiting: 2mins")
            time.sleep(600)
    i = 0
    for sres in results:
        print('hit')
        if goodHit.goodHit(query, sres.text_matches):
            res = sres.repository
            left = g.get_rate_limit()
            if left.core.remaining < 100:
                reset = left.core.reset
                diff = int(reset.strftime('%s')) \
                    - int(time.mktime(time.gmtime()))
                if diff > 0:
                    print('pausing . . for ' + str(diff) + 'sec')
                    time.sleep(diff)
            if silent is False:
                print(str(i) + ' ' + res.full_name
                      + ' (remaining GitHub API calls: '
                      + str(left.core.remaining) + ')')
            repo = {'id': res.id,
                    'name': res.full_name,
                    'url': res.html_url,
                    'description': res.description,
                    'keywords': res.topics}
            i = i + 1
            resset.add(dumps(repo))
    return resset
