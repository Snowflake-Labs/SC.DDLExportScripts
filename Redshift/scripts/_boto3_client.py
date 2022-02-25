import boto3


def get_client():
    """
    This function is separated from the rest of the code for user simplification.
    The purpose of this is to provide the client an easy way to modify the client
    definition in case the organization requires uses of proxy or other kind of
    particular connection requirements.
    More information on how to expand this line of code for other connection requirements
    can be found here: https://boto3.amazonaws.com/v1/documentation/api/latest/guide/configuration.html
    :return: boto3 client object.
    """
    return boto3.client('redshift-data')
