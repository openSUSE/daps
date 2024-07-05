# frozen_string_literal: true

#module Asciidoctor
# A built-in {Converter} implementation that generates DocBook 5 output. The output is inspired by the output produced
# by the docbook45 backend from AsciiDoc.py, except it has been migrated to the DocBook 5 specification.
#class Converter::DocBook5Converter < Converter::Base
#  register_for 'docbook5'

class DapsDocBook5Converter < (Asciidoctor::Converter.for 'docbook5')
  register_for 'docbook5'
end

  def convert_document node
    result = ['<?xml version="1.0" encoding="UTF-8"?>']
    result << ((node.attr? 'toclevels') ? %(<?asciidoc-toc maxdepth="#{node.attr 'toclevels'}"?>) : '<?asciidoc-toc?>') if node.attr? 'toc'
    result << ((node.attr? 'sectnumlevels') ? %(<?asciidoc-numbered maxdepth="#{node.attr 'sectnumlevels'}"?>) : '<?asciidoc-numbered?>') if node.attr? 'sectnums'
    lang_attribute = (node.attr? 'nolang') ? '' : %( xml:lang="#{node.attr 'lang', 'en'}")
    if (root_tag_name = node.doctype) == 'manpage'
      manpage = true
      root_tag_name = 'article'
    end
    root_tag_idx = result.size
    id = node.id
    abstract = find_root_abstract node
    result << (document_info_tag node, abstract) unless node.noheader
    if manpage
      result << '<refentry>'
      result << '<refmeta>'
      result << %(<refentrytitle>#{node.apply_reftext_subs node.attr 'mantitle'}</refentrytitle>) if node.attr? 'mantitle'
      result << %(<manvolnum>#{node.attr 'manvolnum'}</manvolnum>) if node.attr? 'manvolnum'
      result << %(<refmiscinfo class="source">#{node.attr 'mansource', '&#160;'}</refmiscinfo>)
      result << %(<refmiscinfo class="manual">#{node.attr 'manmanual', '&#160;'}</refmiscinfo>)
      result << '</refmeta>'
      result << '<refnamediv>'
      result += (node.attr 'mannames').map {|n| %(<refname>#{n}</refname>) } if node.attr? 'mannames'
      result << %(<refpurpose>#{node.attr 'manpurpose'}</refpurpose>) if node.attr? 'manpurpose'
      result << '</refnamediv>'
    end
    unless (docinfo_content = node.docinfo :header).empty?
      result << docinfo_content
    end
    abstract = extract_abstract node, abstract if abstract
    result << (node.blocks.map {|block| block.convert }.compact.join LF) if node.blocks?
    restore_abstract abstract if abstract
    unless (docinfo_content = node.docinfo :footer).empty?
      result << docinfo_content
    end
    result << '</refentry>' if manpage
    id, node.id = node.id, nil unless id
    # defer adding root tag in case document ID is auto-generated on demand
    result.insert root_tag_idx, %(<#{root_tag_name} xmlns="http://docbook.org/ns/docbook" xmlns:xl="http://www.w3.org/1999/xlink" xmlns:its="http://www.w3.org/2005/11/its" xmlns:trans="http://docbook.org/ns/transclusion" version="5.0"#{lang_attribute}#{common_attributes id}>)
    result << %(</#{root_tag_name}>)
    result.join LF
  end
