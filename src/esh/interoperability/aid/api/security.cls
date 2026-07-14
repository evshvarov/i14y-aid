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
    If ("," _ $Get(properties("Resources")) _ ",") '[ ",%DB_USER:R," {
        Set $Piece(properties("Resources"), ",", *) = "%DB_USER:R"
    }
    Set sc = ##class(Security.Roles).Modify("i14yaid", .properties)
    If $$$ISERR(sc) {
        return $$$ERROR($$$GeneralError, "Error modifying i14yaid role: "_sc)
    }
    Set $NAMESPACE = namespace

    &SQL(GRANT SELECT ON %Dictionary.CompiledClass TO i14yaid)
    If SQLCODE '= 0 {
        return $$$ERROR($$$GeneralError, "Error granting %Dictionary.CompiledClass privileges: "_SQLCODE)
    }
    &SQL(GRANT SELECT ON %Dictionary.CompiledXData TO i14yaid)
    If SQLCODE '= 0 {
        return $$$ERROR($$$GeneralError, "Error granting %Dictionary.CompiledXData privileges: "_SQLCODE)
    }
    &SQL(GRANT SELECT ON %Dictionary.CompiledParameter TO i14yaid)
    If SQLCODE '= 0 {
        return $$$ERROR($$$GeneralError, "Error granting %Dictionary.CompiledParameter privileges: "_SQLCODE)
    }

    return $$$OK
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
    If (":" _ $Get(appProps("MatchRoles")) _ ":") '[ (":" _ appARole _ ":") {
        Set appProps("MatchRoles") = $Get(appProps("MatchRoles")) _ ":" _ appARole
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
