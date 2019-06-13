<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="xml" indent="yes" />

  <xsl:template match="/">
    <dict>
      <xsl:for-each select="Results/ExportObject/ResourceManagementObject">
        <ResourceManagementObject>
          <ObjectIdentifier>
            <xsl:value-of select="replace(ObjectIdentifier, 'urn:uuid:', '')" />
          </ObjectIdentifier>
          <ObjectType>
            <xsl:value-of select="ObjectType" />
          </ObjectType>
          <Name>
            <xsl:value-of select="ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='Name']/Value" />
          </Name>
          <DisplayName>
            <xsl:value-of select="ResourceManagementAttributes/ResourceManagementAttribute[AttributeName='DisplayName']/Value" />
          </DisplayName>
        </ResourceManagementObject>  
      </xsl:for-each>
    </dict>
  </xsl:template>
  
</xsl:stylesheet>