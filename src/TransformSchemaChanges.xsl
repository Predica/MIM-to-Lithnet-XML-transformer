<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:import href="TransformCommon.xsl" />

  <xsl:template match="/">
    <Lithnet.ResourceManagement.ConfigSync>
      <Operations>
        <xsl:comment>
          ObjectTypeDescription
        </xsl:comment>
        <xsl:apply-templates select="Results/ImportObject[ObjectType='ObjectTypeDescription']"/>
      </Operations>
      <Operations>
        <xsl:comment>
          AttributeTypeDescription
        </xsl:comment>
        <xsl:apply-templates select="Results/ImportObject[ObjectType='AttributeTypeDescription']"/>
      </Operations>
      <Operations>
        <xsl:comment>
          BindingDescription
        </xsl:comment>
        <xsl:apply-templates select="Results/ImportObject[ObjectType='BindingDescription']"/>
      </Operations>
      <Operations>
        <xsl:comment>
          SynchronizationFilter
        </xsl:comment>
        <xsl:apply-templates select="Results/ImportObject[ObjectType='SynchronizationFilter']"/>
      </Operations>
      
    </Lithnet.ResourceManagement.ConfigSync>
  </xsl:template>
    
</xsl:stylesheet>