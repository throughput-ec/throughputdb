from re import compile


def shortname(package):
    """Short summary.

    Parameters
    ----------
    package : str
        The full package URL.

    Returns
    -------
    str
        Organization and repository as a string in the form e.g.,
        `SimonGoring/neotoma`

    """
    gh = compile(r'.*github.com\/(:?.*)')
    matcher = gh.match(package).group(1)
    return matcher
