class XmlBuilder

  @@ercXml = "public/assets/patterns/erc.xml"
  @@ercPattern = "public/assets/patterns/ercPattern.xml"
  #
  # Hash of pairs (filed_name = hash of four - containing four variable :: left, top, right, bottom) .
  #
  @@ercFields = {registrationNumber: {left: 0.42, top: 0.025, right: 0.55, bottom: 0.05},
                circle: {left: 0.8, top: 0.025, right: 0.92, bottom: 0.096},
                registeredKeeper: {left: 0.12, top: 0.56, right: 0.43, bottom: 0.62},
                referenceNumber: {left: 0.77, top: 0.54, right: 0.94, bottom: 0.63},
                previousKeeper: {left: 0.03, top: 0.73, right: 0.92, bottom: 0.81}, # => Can't be 'previousRegisteredKeeper' because it is TOO LONG for OCR.SDK
                specialNotes: {left: 0.03, top: 0.84, right: 0.93, bottom: 0.98}}

  def self.ercPattern
    @@ercPattern
  end

  def self.ercXml
    @@ercXml
  end

  def self.ercFields
    @@ercFields
  end

  def self.prepareXmlPattern(doc_type, images)
    #
    # Get images dimensions as table of hashes [[:x, :y],[:x,:y],...]
    #
    dimensions = []
    images.each do |i|
      imageDimensions = FastImage.size(i.image.current_path) # => [x,y]
      dimensions.push({x: imageDimensions[0], y: imageDimensions[1]})
    end

    #
    # Depending on given doc_type build apropriate XML file
    #
    # UPDATE :: It can use one file instead of two - which option is better??
    #
    case doc_type
    when "registration_certificate"
      fields = XmlBuilder.ercFields
      xmlFile = Nokogiri::XML(open(XmlBuilder.ercPattern))
      xmlFile.css("page").each do |page|
        pageDimensions = dimensions.shift
        page.css("text").each do |t|
          fieldId = t.attributes["id"].value
          t.attributes["left"].value = (fields[fieldId.to_sym][:left] * pageDimensions[:x].to_i).to_i.to_s
          t.attributes["top"].value = (fields[fieldId.to_sym][:top] * pageDimensions[:y].to_i).to_i.to_s
          t.attributes["right"].value = (fields[fieldId.to_sym][:right] * pageDimensions[:x].to_i).to_i.to_s
          t.attributes["bottom"].value = (fields[fieldId.to_sym][:bottom] * pageDimensions[:y].to_i).to_i.to_s
        end
      end
    end
    xml = File.open(XmlBuilder.ercXml, 'w') do |f|
      f.write(xmlFile.to_xml)
    end

  end

end
