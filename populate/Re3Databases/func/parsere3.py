def parsere3(uri):
    """Parse Re3Data from XML to Python dictionary.
    This script uses the API for the Registry of Research Data Repositories
    at http://re3data.org/ to pull information about major data repositories
    and then parses it into a usable Python format, from XML.
    API Documentation for Re3Data can be found at: http://re3data.org/api/doc
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
