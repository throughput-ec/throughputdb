from github import RateLimitExceededException
from throughputpy import repoinfo
import time


def getRepo(g, package, rpackage):
    """Get repository information, with try/catch.

    Parameters
    ----------
    g : GitHub
        A Python GitHub object from `PyGithub`.
    package: str
        A package url as a string.
    rpackage : dict
        A dictionary object from the ROpenSci registry.

    Returns
    -------
    type
        An object of type `github.Repository.Repository`.

    """
    while True:
        try:
            repo = repoinfo.repoinfo(g, package)
            break
        except RateLimitExceededException:
            time.sleep(120)
            continue
    annotation = "The GitHub repository uses " \
                 + package + " in a `library()` or `require()` call."
    kw = rpackage.get('keywords')
    parent = {'parentid': repo.id,
              'parentname': package,
              'parentdescription': repo.description,
              'parenturl': repo.html_url,
              'parentkeywords': str(repo.topics) + ',' + kw,
              'annotation': annotation}
    parent['parentkeywords'] = parent.get('parentkeywords').split(',')
    if 'None' in parent.get('parentkeywords'):
        parent.get('parentkeywords').remove('None')
    return parent
