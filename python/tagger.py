def tag(name, *content, **attributes):
    """
    >>> tag('h1')
    '<h1></h1>'
    """

    content_str = ''
    if content:
        content_str = '\n'.join(content)

    return '<{name}>{content}</{name}>'.format(name=name, content=content_str)


if __name__ == '__main__':
    import doctest
    doctest.testmod()

