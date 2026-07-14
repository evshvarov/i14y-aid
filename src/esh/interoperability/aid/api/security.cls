Class esh.interoperability.aid.api.security Extends %RegisteredObject
{

Parameter webapp = "/i14y-aid/api";

ClassMethod SetupSecurity() As %Status
{
    Set tSC = $$$OK
    Set sc = ..IntroduceSQLARole()
    If $$$ISERR(sc) {
        Set tSC = sc
    }
    Set sc = ..AddARole()
    If $$$ISERR(sc) {
        Set tSC = sc
    }
    Set sc = ..AddCORS()
    If $$$ISERR(sc) {
        Set tSC = sc
    }
    Set sc = ..AddARoleToUser()
    If $$$ISERR(sc) {
        Set tSC = sc
    }
    Set sc = ..AddARoleToUser("CSPSystem", "%All")
    If $$$ISERR(sc) {
        Set tSC = sc
    }
    Set sc = ..AddARoleToUser("UnknownUser")
    If $$$ISERR(sc) {
        Set tSC = sc
    }
    Set sc = ..AddARoleToUser("UnknownUser", "%All")
    If $$$ISERR(sc) {
        Set tSC = sc
    }
    return tSC
}

ClassMethod IntroduceSQLARole() As %Status
{
    Set namespace = $Namespace
    &SQL(CREATE ROLE i14yaid)
    If (SQLCODE '= 0) && (SQLCODE '= -100) && (SQLCODE '= -118) {
        return $$$ERROR($$$GeneralError, "Error creating role: "_SQLCODE)
    }

    New $NAMESPACE
    Set $NAMESPACE = "%SYS"
    Set sc = ##class(Security.Roles).Get("i14yaid", .properties)
    If $$$ISERR(sc) {
        return $$$ERROR($$$GeneralError, "Error reading i14yaid role: "_sc)
    }
    If '$Data(properties("Resources")) {
        Set properties("Resources") = ""
    }
    Set resources = properties("Resources")
    Set resources = $Replace(resources, "%DB_USER:R", "%DB_USER:RW")
    Do ..AddResource(.resources, "%DB_USER:RW")
    Do ..AddResource(.resources, "%DB_IRISLIB:R")
    Do ..AddResource(.resources, "%Admin_Operate:U")
    Do ..AddResource(.resources, "%Admin_Manage:U")
    Set properties("Resources") = resources
    Set sc = ##class(Security.Roles).Modify("i14yaid", .properties)
    If $$$ISERR(sc) {
        return $$$ERROR($$$GeneralError, "Error modifying i14yaid role: "_sc)
    }
    Set $NAMESPACE = namespace

    &SQL(GRANT SELECT ON %Dictionary.CompiledClass TO i14yaid)
    If (SQLCODE '= 0) && (SQLCODE '= 100) {
        return $$$ERROR($$$GeneralError, "Error granting %Dictionary.CompiledClass privileges: "_SQLCODE)
    }
    &SQL(GRANT SELECT ON %Dictionary.CompiledXData TO i14yaid)
    If (SQLCODE '= 0) && (SQLCODE '= 100) {
        return $$$ERROR($$$GeneralError, "Error granting %Dictionary.CompiledXData privileges: "_SQLCODE)
    }
    &SQL(GRANT SELECT ON %Dictionary.CompiledParameter TO i14yaid)
    If (SQLCODE '= 0) && (SQLCODE '= 100) {
        return $$$ERROR($$$GeneralError, "Error granting %Dictionary.CompiledParameter privileges: "_SQLCODE)
    }

    return $$$OK
}

ClassMethod AddResource(ByRef resources As %VarString, resource As %VarString) [ Private ]
{
    If ("," _ resources _ ",") [ ("," _ resource _ ",") {
        return
    }
    If resources = "" {
        Set resources = resource
    } Else {
        Set resources = resources _ "," _ resource
    }
    return
}

ClassMethod AddARoleToUser(user As %VarString = "CSPSystem", ARole As %VarString = "i14yaid") As %Status
{
    New $NAMESPACE
    Set $NAMESPACE = "%SYS"

    Set status = ##class(Security.Users).Get(user, .userProps)
    If $$$ISERR(status) {
        return status
    }
    If '$Data(userProps("Roles")) {
        Set userProps("Roles") = ""
    }
    If ("," _ userProps("Roles") _ ",") '[ ("," _ ARole _ ",") {
        Set $Piece(userProps("Roles"), ",", *) = ARole
    }
    Set status = ##class(Security.Users).Modify(user, .userProps)
    return status
}

ClassMethod AddARole(appname As %VarString = "", appARole As %VarString = "i14yaid") As %Status
{
    New $NAMESPACE
    Set $NAMESPACE = "%SYS"

    If appname = "" {
        Set appname = ..#webapp
    }
    Set status = ##class(Security.Applications).Get(appname, .appProps)
    If $$$ISERR(status) {
        return status
    }
    If '$Data(appProps("MatchRoles")) {
        Set appProps("MatchRoles") = ""
    }
    If (":" _ appProps("MatchRoles") _ ":") '[ (":" _ appARole _ ":") {
        Set appProps("MatchRoles") = appProps("MatchRoles") _ ":" _ appARole
    }
    Set status = ##class(Security.Applications).Modify(appname, .appProps)
    return status
}

ClassMethod AddCORS(appname As %VarString = "") As %Status
{
    New $NAMESPACE
    Set $NAMESPACE = "%SYS"

    If appname = "" {
        Set appname = ..#webapp
    }
    Set status = ##class(Security.Applications).Get(appname, .appProps)
    If $$$ISERR(status) {
        return status
    }
    Set appProps("CorsAllowlist") = "*"
    Set appProps("CorsCredentialsAllowed") = 1
    Set appProps("CorsHeadersList") = "Content-Type,Authorization,Accept-Language,X-Requested-With,session"
    Set status = ##class(Security.Applications).Modify(appname, .appProps)
    return status
}

}
