<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:import href="TransformCommon.xsl" />

  <xsl:template match="/">
    <Lithnet.ResourceManagement.ConfigSync>

      <Operations>
        <xsl:comment>
          Reference only
        </xsl:comment>
        <xsl:apply-templates select="Results/ImportObject[State='Resolve']"/>
      </Operations>
      
      <Operations>
        <xsl:comment>
          EmailTemplate
        </xsl:comment>
        <xsl:apply-templates select="Results/ImportObject[ObjectType='EmailTemplate']"/>
      </Operations>
      
      <Operations>
        <xsl:comment>
          FilterScope
        </xsl:comment>
        <xsl:apply-templates select="Results/ImportObject[ObjectType='FilterScope']"/>
      </Operations>

      <Operations>
        <xsl:comment>
          Set
        </xsl:comment>
        <xsl:apply-templates select="Results/ImportObject[ObjectType='Set']"/>
      </Operations>

      <Operations>
        <xsl:comment>
          ActivityInformationConfiguration
        </xsl:comment>
        <xsl:apply-templates select="Results/ImportObject[ObjectType='ActivityInformationConfiguration']"/>
      </Operations>

      <Operations>
        <xsl:comment>
          WorkflowDefinition
        </xsl:comment>
        <xsl:apply-templates select="Results/ImportObject[ObjectType='WorkflowDefinition']"/>
      </Operations>

      <Operations>
        <xsl:comment>
          ManagementPolicyRule
        </xsl:comment>
        <xsl:apply-templates select="Results/ImportObject[ObjectType='ManagementPolicyRule']"/>
      </Operations>

      <Operations>
        <xsl:comment>
          SearchScopeConfiguration
        </xsl:comment>
        <xsl:apply-templates select="Results/ImportObject[ObjectType='SearchScopeConfiguration']"/>
      </Operations>

      <Operations>
        <xsl:comment>
          NavigationBarConfiguration
        </xsl:comment>
        <xsl:apply-templates select="Results/ImportObject[ObjectType='NavigationBarConfiguration']"/>
      </Operations>

      <Operations>
        <xsl:comment>
          HomepageConfiguration
        </xsl:comment>
        <xsl:apply-templates select="Results/ImportObject[ObjectType='HomepageConfiguration']"/>
      </Operations>

      <Operations>
        <xsl:comment>
          PortalUIConfiguration
        </xsl:comment>
        <xsl:apply-templates select="Results/ImportObject[ObjectType='PortalUIConfiguration']"/>
      </Operations>

      <Operations>
        <xsl:comment>
          RCDC
        </xsl:comment>
        <xsl:apply-templates select="Results/ImportObject[ObjectType='ObjectVisualizationConfiguration']"/>
      </Operations>
      
    </Lithnet.ResourceManagement.ConfigSync>
  </xsl:template>

</xsl:stylesheet>