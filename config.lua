Logger = {}

Logger.Endpoint = ""
Logger.ServerPort = 25252
Logger.ServerName = ""
Logger.Debug = true
Logger.Target = "GrayLog"

Logger.EnableStreamFilter = true
Logger.StreamFilterKey = "permission"
Logger.StreamFilterValue = "Admin"
Logger.Framework = "QB" -- Valid values: QB, ESX, Standalone
Logger.UseQBExport = true
Logger.CoreName = "qb-core"
