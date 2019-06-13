<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="xml" indent="yes" />

   <xsl:template match="Results/ImportObject/State">
    <xsl:if test=".='Put'">Update</xsl:if>
    <xsl:if test=".='Create'">Add Update</xsl:if>
    <xsl:if test=".='Resolve'">None</xsl:if>
    <xsl:if test=".='Delete'">Delete</xsl:if>
  </xsl:template>

  <xsl:template match="Results/ImportObject/Changes/ImportChange/Operation">
    <xsl:if test=".='Add'">add</xsl:if>
    <xsl:if test=".='Replace'">replace</xsl:if>
    <xsl:if test=".='Delete'">delete</xsl:if>
    <xsl:if test=".='None'">
      <xsl:if test="count(../../ImportChange[AttributeName=current()/../AttributeName]) > 1">add</xsl:if>
      <xsl:if test="not(count(../../ImportChange[AttributeName=current()/../AttributeName]) > 1)">replace</xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template match="Results/ImportObject">
    <xsl:for-each select=".">
      <xsl:comment>
        <xsl:text>SourceObjectIdentifier: </xsl:text>
        <xsl:value-of select="SourceObjectIdentifier" />
      </xsl:comment>
      <ResourceOperation>
        <xsl:attribute name="operation">
          <xsl:apply-templates select="State"/>
        </xsl:attribute>
        <xsl:attribute name="resourceType">
          <xsl:value-of select="ObjectType" />
        </xsl:attribute>
        <xsl:attribute name="id">
          <xsl:value-of select="ObjectType" />
          <xsl:text> </xsl:text>
          <xsl:if test="AnchorPairs/JoinPair[AttributeName='DisplayName' or AttributeName='Name']/AttributeValue">
            <xsl:value-of select="replace(AnchorPairs/JoinPair[AttributeName='DisplayName' or AttributeName='Name']/AttributeValue, ':', '')" />
          </xsl:if>
          <xsl:if test="not(AnchorPairs/JoinPair[AttributeName='DisplayName' or AttributeName='Name']/AttributeValue)">
            <xsl:if test="SourceObjectIdentifier">
              <xsl:value-of select="SourceObjectIdentifier" />
            </xsl:if>
            <xsl:if test="not(SourceObjectIdentifier)">
              <xsl:value-of select="TargetObjectIdentifier" />
            </xsl:if>
          </xsl:if>
        </xsl:attribute>
        <AnchorAttributes>
          <xsl:if test="AnchorPairs/JoinPair">
            <xsl:for-each select="AnchorPairs/JoinPair">
              <AnchorAttribute>
                <xsl:value-of select="AttributeName" />
              </AnchorAttribute>
            </xsl:for-each>
          </xsl:if>
          <xsl:if test="not(AnchorPairs/JoinPair)">
            <!--For Delete operation there is no AnchorPairs, so let's use ObjectID-->
            <AnchorAttribute>ObjectID</AnchorAttribute>
          </xsl:if>
        </AnchorAttributes>
        <AttributeOperations>
          <xsl:if test="State!='Create'">
            <!--Adding Anchor attributes values-->
            <xsl:if test="AnchorPairs/JoinPair">
              <xsl:for-each select="AnchorPairs/JoinPair"> <!--[AttributeName='DisplayName' or AttributeName='Name' or AttributeName='BoundAttributeType' or AttributeName='BoundObjectType']-->
                <AttributeOperation operation="none">
                  <xsl:attribute name="name">
                    <xsl:value-of select="AttributeName" />
                  </xsl:attribute>
                  <xsl:choose>
                    <xsl:when test="starts-with(AttributeValue, 'urn:uuid:')">
                      <!--If this is a reference to another object-->
                      <xsl:if test="/Results/ImportObject[SourceObjectIdentifier=current()/AttributeValue]">
                        <!--If the object is defined in the source xml-->
                        <xsl:attribute name="type">xmlref</xsl:attribute>
                        <xsl:value-of select="/Results/ImportObject[SourceObjectIdentifier=current()/AttributeValue]/ObjectType" />
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="replace(/Results/ImportObject[SourceObjectIdentifier=current()/AttributeValue]/AnchorPairs/JoinPair/AttributeValue, ':', '')" />
                      </xsl:if>
                      <xsl:if test="not(/Results/ImportObject[SourceObjectIdentifier=current()/AttributeValue])">
                        <!--If the object is not defined in the source xml-->
                        <xsl:attribute name="type">ref</xsl:attribute>
                        <xsl:text>NOT PRESENT IN XML: </xsl:text>
                        <xsl:value-of select="AttributeValue" />
                      </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="AttributeValue" />
                    </xsl:otherwise>
                  </xsl:choose>
                </AttributeOperation>
              </xsl:for-each>
            </xsl:if>
            <xsl:if test="not(AnchorPairs/JoinPair)">
              <!--For Delete operation there is no AnchorPairs, so let's use ObjectID to build reference -->
              <AttributeOperation operation="none">
                <xsl:attribute name="name">
                  <xsl:text>ObjectID</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="type">ref</xsl:attribute>
                <xsl:text>NOT PRESENT IN XML: </xsl:text>
                <xsl:value-of select="TargetObjectIdentifier" />
              </AttributeOperation>
            </xsl:if>
          </xsl:if>
          <!--Other attributes-->
          <xsl:for-each select="Changes/ImportChange[AttributeName!='ObjectType']">
            <AttributeOperation>
              <xsl:attribute name="operation">
                <xsl:apply-templates select="Operation"/>
              </xsl:attribute>
              <xsl:attribute name="name">
                <xsl:value-of select="AttributeName" />
              </xsl:attribute>
              <xsl:choose>
                <xsl:when test="starts-with(AttributeValue, 'urn:uuid:')">
                  <!--If this is a reference to another object-->
                  <xsl:if test="/Results/ImportObject[SourceObjectIdentifier=current()/AttributeValue]">
                    <!--If the object is defined in the source xml-->
                    <xsl:attribute name="type">xmlref</xsl:attribute>
                    <xsl:value-of select="/Results/ImportObject[SourceObjectIdentifier=current()/AttributeValue]/ObjectType" />
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="replace(/Results/ImportObject[SourceObjectIdentifier=current()/AttributeValue]/AnchorPairs/JoinPair/AttributeValue, ':', '')" />
                  </xsl:if>
                  <xsl:if test="not(/Results/ImportObject[SourceObjectIdentifier=current()/AttributeValue])">
                    <!--If the object is not defined in the source xml-->
                    <xsl:attribute name="type">ref</xsl:attribute>
                    <xsl:text>NOT PRESENT IN XML: </xsl:text>
                    <xsl:value-of select="AttributeValue" />
                  </xsl:if>
                </xsl:when>
                <xsl:when test="starts-with(AttributeValue, '&lt;Filter')">
                  <xsl:attribute name="type">filter</xsl:attribute>
                  <xsl:value-of select="substring-before(substring-after(AttributeValue, '&gt;'),'&lt;')" />
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="AttributeValue" />
                </xsl:otherwise>
              </xsl:choose>
            </AttributeOperation>
          </xsl:for-each>
        </AttributeOperations>
      </ResourceOperation>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>