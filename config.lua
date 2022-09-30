Logger = {}

Logger.Endpoint = GetConvar("LoggerEndPoint", "")
Logger.ServerPort = 30120
Logger.ServerName = ""
Logger.Debug = true
Logger.Target = "Loki"
Logger.BulkTimer = 30 -- currently only works for loki

Logger.EnableStreamFilter = true
Logger.StreamFilterKey = "permission"
Logger.StreamFilterValue = "Admin"
Logger.Framework = "QB" -- Valid values: QB, ESX, Standalone
Logger.UseQBExport = true
Logger.CoreName = "qb-core"