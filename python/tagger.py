def tag(name, *content, **attributes):

    content_str = ''
    if content:
        content_str = '\n'.join(content)

    return '<{name}>{content}</{name}>'.format(name=name, content=content_str)


if __name__ == '__main__':
    print(tag('h1'))
    print(tag('h2', 'foo', 'bar'))

