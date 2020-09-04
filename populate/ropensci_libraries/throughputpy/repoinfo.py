from throughputpy import shortname


def repoinfo(g, package):
    """Short summary.

    Parameters
    ----------
    g : GitHub
        A Python GitHub object from `PyGithub`.
    package : type
        Description of parameter `package`.

    Returns
    -------
    type
        Description of returned object.

    """
    matcher = shortname.shortname(package)
    repo = g.get_repo(matcher)
    return repo
