require 'rex/parser/outpost24_nokogiri'

module Msf::DBManager::Import::Outpost24
  def import_outpost24_noko_stream(args={},&block)
    if block
      doc = Rex::Parser::Outpost24Document.new(args,framework.db) {|type, data| yield type,data }
    else
      doc = Rex::Parser::Outpost24Document.new(args,self)
    end
    parser = ::Nokogiri::XML::SAX::Parser.new(doc)
    parser.parse(args[:data])
  end

  def import_outpost24_xml(args={}, &block)
    bl = validate_ips(args[:blacklist]) ? args[:blacklist].split : []
    wspace = args[:wspace] || workspace
    if Rex::Parser.nokogiri_loaded
      parser = "Nokogiri v#{::Nokogiri::VERSION}"
      noko_args = args.dup
      noko_args[:blacklist] = bl
      noko_args[:wspace] = wspace
      if block
        yield(:parser, parser)
        import_outpost24_noko_stream(noko_args) {|type, data| yield type,data}
      else
        import_outpost24_noko_stream(noko_args)
      end
      return true
    else # Sorry
      raise Msf::DBImportError.new("Could not import due to missing Nokogiri parser. Try 'gem install nokogiri'.")
    end
  end
end