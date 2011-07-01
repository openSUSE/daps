BEGIN{
    xmldecl="<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
    doctype="<!DOCTYPE svg PUBLIC \"-//W3C//DTD SVG 1.1//EN\"\n\
        \"http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd\">"
    svg="<svg xml:lang=\"en\" font-family=\"monospace\" font-size=\"8pt\" width=\"12cm\" height=\"7cm\">"
    rect="<rect id=\"rect\" fill=\"white\" stroke=\"black\" stroke-width=\"0.4pt\" x=\"0\" y=\"0\"\n\
      width=\"100%\" height=\"100%\"/>"
    text="<text xml:space=\"preserve\" x=\"10\" y="
    y=20
    yinc=15
    
    print xmldecl
    print doctype
    print svg
    print rect
}

{
    printf ("%s\"%d\">%s</text>\n", text, y, $0)
    y += yinc
}

END{
    print "</svg>"
}



