<?xml version="1.0" encoding="UTF-8"?>
<soapenv:Envelope xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/"
 xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
 xmlns:xsd="http://www.w3.org/2001/XMLSchema"
 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
<soapenv:Body>
<RetrievePropertiesResponse xmlns="urn:vim25"><returnval><obj type="ComputeResource">domain-s141</obj><propSet><name>name</name><val xsi:type="xsd:string">ESXiHost</val></propSet><propSet><name>parent</name><val type="Folder" xsi:type="ManagedObjectReference">group-h4</val></propSet></returnval><returnval><obj type="Folder">group-h4</obj><propSet><name>name</name><val xsi:type="xsd:string">host</val></propSet><propSet><name>parent</name><val type="Datacenter" xsi:type="ManagedObjectReference">datacenter-2</val></propSet></returnval><returnval><obj type="Datacenter">datacenter-2</obj><propSet><name>name</name><val xsi:type="xsd:string">MainDatacenter</val></propSet><propSet><name>parent</name><val type="Folder" xsi:type="ManagedObjectReference">group-d1</val></propSet></returnval><returnval><obj type="Folder">group-d1</obj><propSet><name>name</name><val xsi:type="xsd:string">Datacenters</val></propSet></returnval></RetrievePropertiesResponse>
</soapenv:Body>
</soapenv:Envelope>
