def parsere3(uri):
    """Parse Re3Data from XML to Python dictionary.

    Parameters
    ----------
    uri : string
        A web address (https://www.re3data.org/api/v1/repositories)

    Returns
    -------
    dict
        The rendered re3data object from XML.

    """

    import requests
    import xmltodict

    file = requests.get(uri)
    data = xmltodict.parse(file.content)
    return data
