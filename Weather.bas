B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=StaticCode
Version=7.3
@EndOfDesignText@
'Code module				http://openweathermap.org
'Subs in this code module will be accessible from all modules.
Sub Process_Globals
	'These global variables will be declared once when the application starts.
	'These variables can be accessed from all modules.
	
	Dim AppID As String = ""'put openweathermap API key here
	
	Dim CurrentUnits As String, CurrentCity As String, LastUpdate As Long, UpdatePeriod As Long , NextUpdate As Long ,CurrentFormat As String = "json"
	Dim NeedsUpdate As Boolean , GetDays As Int = 5, CurrentCityID As Int  = -1
	
	Type WeatherData (City As String, Country As String , CityID As Int, Population As Long , Latitude As String, Longitude As String, Days As List, Units As String, UnitsSpeed As String, UnitsDistance As String, UnitsPressure As String)
	Type WeatherDay  (Date As Long, Clouds As Float, Humidity As Float, Pressure As Float, Speed As Float, Rain As Float, Snow As Float, Deg As Float, Morning As Float, Minimum As Float, Night As Float, Evening As Float, Maximum As Float, Day As Float, Icons As List)
	Type WeatherIcon (ID As Int, Icon As String, Description As String, Name As String)
	Dim CurrentWeather As WeatherData , NoTemp As Int = -99999, Provider As Int 
End Sub

Sub ProviderName(Index As Int) As String 
	If Index = -1 Then Index = Provider
	If Index = -2 Then Return PossibleValues(2).Length
	Dim Values() As String = PossibleValues(2)
	Return Values(Index)
End Sub

'Destination can be of the following forms:
'city,state/province/county (ie: burlington, ontario)		longitude,latitude       cityID number       city (ie: london)
'Formats: xml, json, html
'Units: metric, imperial, kelvin
'Days: 0=weather mode, >0=forcast mode
Sub GenerateURL(Destination As String, Format As String, Units As String, Days As Int) As String 
	Dim tempstr As String, tempstr2() As String, Query As String, STR As StringUtils
	If Destination.trim.Length=0 Or Not(API.IsConnected) Then Return ""
	Select Case Provider
		Case 0'openweathermap
			tempstr = "http://api.openweathermap.org/data/2.5/"
			If Days = 0 Then tempstr = tempstr & "weather?" Else tempstr = tempstr & "forecast/daily?"
			If Destination.Contains(",") Then 
				tempstr2 = Regex.Split(",", Destination)
				If IsNumber(tempstr2(0)) And IsNumber(tempstr2(1)) Then
					tempstr = tempstr & "lat=" & tempstr2(0) & "&lon=" & tempstr2(1)
				Else
					tempstr = tempstr & "q=" & Destination'.Replace(",", "%2C")
				End If
			Else If IsNumber(Destination) Then
				tempstr = tempstr & "id=" & Destination
			Else
				tempstr = tempstr & "q=" & Destination
			End If	
			If Format.Length=0 Then Format = API.IIF( CurrentFormat.Length=0, "json", CurrentFormat) 
			If Units.Length=0 Then Units = API.IIF( CurrentUnits.Length=0, "metric", CurrentUnits)
			tempstr = tempstr & "&mode=" & Format.ToLowerCase & "&units=" & Units.ToLowerCase 
			If Days>0 Then tempstr = tempstr & "&cnt=" & Days
			If AppID.Length>0 Then tempstr = tempstr & "&APPID=" & AppID
		Case 1'yahoo
			tempstr = "http://query.yahooapis.com/v1/public/yql"
			Query = "select * from weather.forecast where woeid in (select woeid from geo.places(1) where text=" & """" & Destination & """" & ")"
			If Format.Length=0 Then Format = API.IIF( CurrentFormat.Length=0, "json", "xml") 
			tempstr = tempstr & "?q=" & STR.EncodeUrl(Query, "UTF8").Replace("+", " ") & "&format=" & Format
	End Select
	Return tempstr'.Replace(" ", "%20")
End Sub

Sub ChangeUpdatePeriod(Value As Int)
	If Value>0 Then UpdatePeriod=Value
	If CurrentCity.Length>0 Then NextUpdate		= LastUpdate + (UpdatePeriod * DateTime.TicksPerHour)
	If DateTime.Now > NextUpdate Then NeedsUpdate = True
End Sub
Sub ChangeCity(NewCity As String)
	CurrentCity = NewCity
	CurrentCityID = -1
	NeedsUpdate = True
End Sub
Sub ChangeProvider(NewProvider As Int)
	Provider = NewProvider
	File.Delete(LCAR.DirDefaultExternal, "weather.json")
	NeedsUpdate = True
End Sub

Sub LoadWeatherSettings(Save As Boolean)
	CurrentUnits 	= API.HandleSetting("Weather.Units", 	CurrentUnits, 	"metric", 	Save)
	CurrentCity 	= API.HandleSetting("Weather.City", 	CurrentCity, 	"", 		Save)
	LastUpdate		= API.HandleSetting("Weather.Last", 	LastUpdate, 	0, 			Save)
	UpdatePeriod	= API.HandleSetting("Weather.Period",	UpdatePeriod,	24,			Save)
	CurrentCityID   = API.HandleSetting("Weather.CityID", 	CurrentCityID, 	-1, 		Save)
	Provider 		= API.HandleSetting("Weather.Provider", Provider,		0,			Save)
	ChangeUpdatePeriod(UpdatePeriod)
	If Not(Save) Then CheckWeather("", False)
End Sub

'Index: 0=units, 1=hours, 2=providers
Sub PossibleValues(Index As Int) As String() 
	Select Case Index
		Case 0: Return Array As String("METRIC", "IMPERIAL", "KELVIN")'units
		Case 1: Return Array As String("3", "6", "12", "24", "48", "72")'time period (hours)
		Case 2: Return Array As String("OPENWEATHERMAP", "POWERED BY YAHOO!")'providers
	End Select
End Sub

Sub CanUpdateYet As Boolean 
	If File.Exists(LCAR.DirDefaultExternal, "weather.json") Then Return File.LastModified(LCAR.DirDefaultExternal, "weather.json") < DateTime.Now - (DateTime.TicksPerMinute *10) 
	Return True
End Sub

Sub ChangeUpdateTime(Time As Long)As Boolean 
	If Time = 0 Then
		Log("Next update: " & LCAR.Stardate(-2, NextUpdate, False,2))
		If NextUpdate <= DateTime.Now Then
			CheckWeather("", False)
			Return True
		End If
	Else
		LastUpdate = Time
		ChangeUpdatePeriod(0)
	End If
End Sub

Sub CheckWeather(Data As String, NeedsSaving As Boolean ) As Boolean 
	Dim tempstr As String = "weather.json", FileDate As Long, Destination As String 
	If Data.Length=0 Then 
		If File.Exists(LCAR.DirDefaultExternal, tempstr) Then
			FileDate = File.LastModified(LCAR.DirDefaultExternal, tempstr)
			If FileDate >= DateTime.Now - (DateTime.TicksPerMinute *10) Then NeedsUpdate = False
			If FileDate <= NextUpdate And Not(NeedsUpdate) And API.IsConnected Then'was >= lastupdate
				ChangeUpdateTime(FileDate )
				Return CheckWeather(File.ReadString(LCAR.DirDefaultExternal, tempstr), False)
			Else
				File.Delete(LCAR.DirDefaultExternal, tempstr)
			End If
		End If
		
		Select Case Provider
			Case 0: 	Destination = API.IIF(CurrentCityID>-1, CurrentCityID, CurrentCity)'OPENWEATHERMAP
			Case Else: 	Destination = CurrentCity'YAHOO
		End Select
		tempstr = GenerateURL(Destination,CurrentFormat,"metric",GetDays)
		'tempstr = GenerateURL(API.IIF(CurrentCityID>-1, CurrentCityID, CurrentCity),CurrentFormat,CurrentUnits,GetDays)

		If tempstr.Length>0 Then
			If Not(STimer.Downloader.IsInitialized) Then STimer.Downloader.Initialize("Downloader", STimer)
			ChangeUpdateTime( DateTime.Now )
			STimer.Downloader.Download(tempstr)
		End If
	Else	
		If NeedsSaving Then File.WriteString(LCAR.DirDefaultExternal, tempstr, Data)
		CurrentWeather = ParseWeather(Data)
		If CurrentWeather.IsInitialized Then 
			CurrentCityID = CurrentWeather.CityID 
			CallSub(Widgets,"Widget_UpdateSettings")
			If Main.CurrentSection = 48 Then LCARSeffects4.UpdateWeather'(CurrentWeather)
		End If 
	End If
End Sub
Sub GetUnit(Units As String) As String 
	Select Case Units.ToLowerCase.Replace("°", "")
		Case "imperial", "f": Return "°F"
		Case "metric", "c": Return "°C"
		Case "kelvin", "k": Return "°K"
	End Select
End Sub

Sub ConvertWEAtoImperial(WEA As WeatherData)
	Dim temp As Int, TheDay As WeatherDay
	For temp = 0 To WEA.Days.Size-1
		ConvertDayToImperial( WEA.Days.get(temp) )
	Next
End Sub
Sub ConvertDayToImperial(TheDay As WeatherDay) As WeatherDay
	TheDay.Pressure = TheDay.Pressure * 0.0145037738				'convert to: pounds per square inch
	TheDay.Speed = 	  TheDay.Speed * 1.09361						'convert to: yards per second
	TheDay.Snow = 	  TheDay.Snow * 0.0393701						'convert to: inches per 3 hours
	TheDay.Rain = 	  TheDay.Rain * 0.0393701						'convert to: inches per 3 hours
	Return TheDay
End Sub
Sub ConvertDayToMetric(TheDay As WeatherDay, DesiredUnits As String)  As WeatherDay
	'units = {distance=mi, pressure=in, speed=mph, temperature=F} DesiredUnits= °C or °K
	TheDay.Pressure = TheDay.Pressure * 6894.76 'psi to hPa
	TheDay.Speed = TheDay.Speed * 0.44704 'mph to m/s
	TheDay.Snow = TheDay.Snow * 25.4'inches to mm
	TheDay.Rain = TheDay.Snow * 25.4'inches to mm
	Return TheDay
End Sub
Sub ParseWeather(Data As String) As WeatherData
	Dim JSON As JSONParser ,Map1 As List,m As Map , WEA As WeatherData ,temp As Int ,m2 As Map, m3 As Map , Map2 As List ,temp2 As Int 
	Dim Offset As Long = DateTime.GetTimeZoneOffsetAt(DateTime.Now) * DateTime.TicksPerHour 
	Try 
		JSON.Initialize(Data)
	Catch 
		Return WEA 
	End Try
	WEA.Initialize
	WEA.Units = CurrentUnits
	WEA.Days.Initialize
	m = JSON.NextObject
	
	If WEA.Units.EqualsIgnoreCase("imperial") Then
		WEA.UnitsSpeed = "y/s"
		WEA.UnitsDistance = "″"
		WEA.Units="°F"
		WEA.UnitsPressure = "psi"
	Else
		WEA.UnitsPressure = "hPa"
		WEA.UnitsSpeed = "m/s"
		WEA.UnitsDistance = "mm"
		WEA.Units = API.IIF(WEA.Units.EqualsIgnoreCase("metric"), "°C", "°K")
	End If
	
	Select Case Provider
		Case 0'OPENWEATHERMAP
			m2 = m.Get("city")
			If m2.IsInitialized Then
				WEA.City = 			m2.GetDefault("name", "")
				WEA.Country=		m2.GetDefault("country", "")
				WEA.Population =	m2.GetDefault("population", 0)
				WEA.CityID = 		m2.GetDefault("id", -1)
				m2 = m2.Get("coord")
				If m2.IsInitialized Then
					WEA.Latitude = m2.GetDefault("lat", "")
					WEA.Longitude = m2.GetDefault("lon", "")
									
					Map1 = m.Get("list")
					If Map1.IsInitialized Then
						For temp = 0 To Map1.Size-1
							Dim TheDay As WeatherDay
							TheDay.Initialize
							TheDay.Icons.Initialize 
							'TheDay.Date = 		DateTime.Now + (DateTime.TicksPerDay * temp)
							m = 				Map1.Get(temp)
							TheDay.Clouds = 	m.GetDefault("clouds", NoTemp)'				Cloudiness in % 
							TheDay.Date = 		m.GetDefault("dt", NoTemp)*1000 -Offset'	Time of data receiving in unixtime GMT 
							TheDay.Humidity = 	m.GetDefault("humidity", NoTemp)' 			Humidity in % 
							TheDay.Deg = 		m.GetDefault("deg", NoTemp)'				Wind direction in degrees (meteorological) 
							
							'metric
							TheDay.Pressure =  	m.GetDefault("pressure", NoTemp)' 			Atmospheric pressure in hPa 
							TheDay.Speed = 		m.GetDefault("speed", NoTemp)'				Wind speed in meters per second 
							TheDay.Snow = 		m.GetDefault("snow", NoTemp)'				Precipitation volume mm per 3 hours
							TheDay.Rain =  		m.GetDefault("rain", NoTemp)'				Precipitation volume mm per 3 hours 
							If WEA.Units = "°F" Then ConvertDayToImperial(TheDay)

							Map2 = 				m.Get("weather")
							If Map2.IsInitialized Then
								For temp2 = 0 To Map2.Size-1
									m2 = Map2.Get(temp2)
									If m2.IsInitialized Then
										Dim tempIcon As WeatherIcon 
										tempIcon.Initialize 
										tempIcon.ID = 			m2.GetDefault("id", -1)
										tempIcon.icon = 		m2.GetDefault("icon", "")
										tempIcon.Description = 	m2.GetDefault("description", "")
										tempIcon.Name = 		m2.GetDefault("main", "")
										TheDay.Icons.Add(tempIcon)
									End If
								Next
							End If
							
							m = m.Get("temp")
							If m.IsInitialized Then
								TheDay.Morning = 	Trig.ConvertUnits(0, m.GetDefault("morn", 	NoTemp), WEA.Units, CurrentUnits)
								TheDay.Minimum =	Trig.ConvertUnits(0, m.GetDefault("min", 	NoTemp), WEA.Units, CurrentUnits)
								TheDay.Night =		Trig.ConvertUnits(0, m.GetDefault("night", 	NoTemp), WEA.Units, CurrentUnits)
								TheDay.Evening =	Trig.ConvertUnits(0, m.GetDefault("eve", 	NoTemp), WEA.Units, CurrentUnits)
								TheDay.Maximum =	Trig.ConvertUnits(0, m.GetDefault("max", 	NoTemp), WEA.Units, CurrentUnits)
								TheDay.Day  =		Trig.ConvertUnits(0, m.GetDefault("day", 	NoTemp), WEA.Units, CurrentUnits)
							End If
							WEA.Days.Add(TheDay)
						Next
						WEA.Days.SortType("Date", True)
					End If
				End If
			End If
		Case 1'YAHOO
			m = m.Get("query")
			If m.Get("count") > 0 Then
				m = m.Get("results")
				m = m.Get("channel")
				'm = RemoveItems(m, Array As String("title", "link", "description", "language", "lastBuildDate", "ttl", "image"))				
				m.Put("item", RemoveItems(m.Get("item"), Array As String("title", "link", "pubDate", "description")))
				
				m2 = m.GetDefault("location", "")
				WEA.City = 			m2.GetDefault("city", "") & ", " & m2.GetDefault("region", "")
				WEA.Country=		m2.GetDefault("country", "")
				WEA.CityID = 		m2.GetDefault("id", -1)
				
				m2 = m.Get("item")
				WEA.Latitude = m2.GetDefault("lat", "")
				WEA.Longitude = m2.GetDefault("long", "")
				
				
				'For temp = 0 To m.Size-1 
				'	LogColor( m.GetKeyAt(temp) & " = " & m.GetValueAt(temp), Colors.Blue)
				'Next
				'location = {city=Hamilton, country=Canada, region=ON}
				'units = {distance=mi, pressure=in, speed=mph, temperature=F}
				'wind = {chill=54, direction=150, speed=7}
				'atmosphere = {humidity=94, pressure=30.18, rising=1, visibility=}
				'astronomy = {sunrise=7:37 am, sunset=6:28 pm}
				'image = {title=Yahoo! Weather, width=142, height=18, link=http://weather.yahoo.com, url=http://l.yimg.com/a/i/brand/purplelogo//uh/us/news-wea.gif}
				'item = {lat=43.23, long=-79.85, condition={code=11, date=Tue, 20 Oct 2015 10:59 pm EDT, temp=54, text=Light Rain Shower}, forecast=[{code=26, date=20 Oct 2015, day=Tue, high=64, low=51, text=Sprinkles}, {code=11, date=21 Oct 2015, day=Wed, high=62, low=56, text=AM Light Rain}, {code=30, date=22 Oct 2015, day=Thu, high=60, low=38, text=AM Clouds/PM Sun}, {code=32, date=23 Oct 2015, day=Fri, high=50, low=38, text=Sunny}, {code=26, date=24 Oct 2015, day=Sat, high=58, low=49, text=Cloudy}]}
				

				Map1 = m2.Get("forecast")
				If Map1.IsInitialized Then
					For temp = 0 To Map1.Size-1
						Dim TheDay As WeatherDay
						TheDay.Initialize
						TheDay.Icons.Initialize 
		
						m3 = m2.Get("atmosphere")
						TheDay.Humidity = 	m.GetDefault("humidity", NoTemp)' 			Humidity in % 
						TheDay.Pressure =  	m.GetDefault("pressure", NoTemp)' 			Atmospheric pressure in inches 

						m3 = m2.Get("wind")
						TheDay.Deg = 		m.GetDefault("direction", NoTemp)'			Wind direction in degrees (meteorological) 
						TheDay.Speed = 		m.GetDefault("speed", NoTemp)'				Wind speed in meters per miles per hour 

						m3 = Map1.Get(temp)
						Dim tempIcon As WeatherIcon 
						tempIcon.Initialize 
						TheDay.Date = 			YahooDate(m3.GetDefault("date", -1))'	Time of data receiving in unixtime GMT 
						tempIcon.ID = 			YahooToOWMcode(m3.GetDefault("code", -1))
						tempIcon.icon = 		CodeToImage(m3.GetDefault("code", -1))
						tempIcon.Description = 	m3.GetDefault("text", "")
						tempIcon.Name = 		m3.GetDefault("text", "")
						TheDay.Icons.Add(tempIcon)

						TheDay.Morning = 	Trig.ConvertUnits(0, m3.GetDefault("low", 	NoTemp), "°F", CurrentUnits)
						TheDay.Minimum =	Trig.ConvertUnits(0, m3.GetDefault("low", 	NoTemp), "°F", CurrentUnits)
						TheDay.Night =		Trig.ConvertUnits(0, m3.GetDefault("low", 	NoTemp), "°F", CurrentUnits)
						TheDay.Evening =	Trig.ConvertUnits(0, m3.GetDefault("low", 	NoTemp), "°F", CurrentUnits)
						TheDay.Maximum =	Trig.ConvertUnits(0, m3.GetDefault("high", 	NoTemp), "°F", CurrentUnits)
						TheDay.Day  =		Trig.ConvertUnits(0, m3.GetDefault("low", 	NoTemp), "°F", CurrentUnits)
						
						If CurrentUnits = "°F" Then 
							WEA.UnitsSpeed = "mph"
						Else
							TheDay = ConvertDayToMetric(TheDay, CurrentUnits)
						End If
						WEA.Days.Add(TheDay)
					Next
					WEA.Days.SortType("Date", True)
				End If
			End If

	End Select
	'LogColor("STR WEA:", Colors.Red)
	'Log(WEA)
	'LogColor("END WEA:", Colors.Red)
	Return WEA
End Sub

Sub YahooDate(Date As String) As Long
	Dim tempstr() As String = Regex.Split(" ", Date)
	Select Case tempstr.Length
		Case 7
			'0    1  2   3    4    5  6
			'Thu, 22 Oct 2015 7:58 am EDT
			Return API.MakeDate(tempstr(3), GetMonth(tempstr(2)), tempstr(1), 0,0,0,0)
		Case 3
			'0  1   2
			'22 Oct 2015
			Return API.MakeDate(tempstr(2), GetMonth(tempstr(1)), tempstr(0), 0,0,0,0)
	End Select
End Sub
Sub GetMonth(Month As String) As Int
	Dim Months As List = Array As String("jan", "feb", "mar", "apr", "may", "jun", "jul", "aug", "sep", "oct", "nov", "dec")
	Return Months.IndexOf(Month.ToLowerCase) + 1
End Sub

Sub RemoveItems(M2 As Map, Values As List) As Map 
	Dim temp As Int 
	For temp = 0 To Values.Size - 1 
		M2.Remove(Values.Get(temp))
	Next
	Return M2
End Sub

Sub HasWeatherData(Data As WeatherData) As Boolean 
	If Data.IsInitialized Then
		If Data.Days.IsInitialized Then Return Data.Days.Size>0
	End If
End Sub

Sub CurrentTimeOfDay As Int
	Dim Hour As Int = DateTime.GetHour(DateTime.Now)'as 6 hourly (Morning, Day, Evening, Night)
	If Hour <= 6 Then Return 0
	If Hour <=12 Then Return 1
	If Hour <=18 Then Return 2
	Return 3
End Sub
Sub CurrentTemperature(Today As WeatherDay) As Float
	Select Case CurrentTimeOfDay
		Case 0:Return Today.Morning
		Case 1:Return Today.Day
		Case 2:Return Today.Evening
		Case 3:Return Today.Night
	End Select
End Sub
Sub IsDangerous(Icon As WeatherIcon) As Int 
	Select Case Icon.ID 
		Case 503,504,511,522,602,611,612,622,903,904,905,958: Return 1
		Case 762,771,781,900,901,902,906,959,961,962: Return 2
	End Select
End Sub

Sub FindToday(Data As WeatherData) As Int
	Dim temp As Int , tempDay As WeatherDay 
	For temp = 0 To Data.Days.Size-1
		tempDay = Data.days.Get(temp)
		If DateTime.GetDayOfYear( tempDay.Date ) = DateTime.GetDayOfYear( DateTime.Now) And DateTime.GetYear(tempDay.Date) = DateTime.GetYear(DateTime.Now) Then Return temp
	Next
	Return -1
End Sub

Sub YahooToOWMcode(Code As Int) As Int
	Select Case Code
		Case 0: Return 900'tornado
		Case 1: Return 901'tropical storm
		Case 2: Return 902'hurricane
		Case 3: Return 212'severe thunderstorms
		Case 4: Return 211'thunderstorms
		Case 5: Return 616'mixed rain AND snow
		Case 6: Return 612'mixed rain AND sleet
		Case 7: Return 616'mixed snow AND sleet
		Case 8: Return 511'freezing drizzle
		Case 9: Return 301'drizzle
		Case 10: Return 511'freezing rain
		Case 11, 12: Return 321'showers
		Case 13: Return 622'snow flurries
		Case 14: Return 615'light snow showers
		Case 15: Return 602'blowing snow
		Case 16: Return 601'snow
		Case 17: Return 906'hail
		Case 18: Return 611'sleet
		Case 19: Return 761'dust
		Case 20: Return 741'foggy
		Case 21: Return 721'haze
		Case 22: Return 711'smoky
		Case 23: Return 905'blustery
		Case 24: Return 905'windy
		Case 25: Return 903'cold
		Case 26: Return 802'cloudy
		Case 27: Return 804'mostly cloudy (night)
		Case 28: Return 804'mostly cloudy (day)
		Case 29: Return 804'partly cloudy (night)
		Case 30: Return 804'partly cloudy (day)
		Case 31: Return 800'clear (night)
		Case 32: Return 800'sunny
		Case 33: Return 951'fair (night)
		Case 34: Return 951'fair (day)
		Case 35: Return 906'mixed rain AND hail
		Case 36: Return 904'hot
		Case 37: Return 210'isolated thunderstorms
		Case 38: Return 211'scattered thunderstorms
		Case 39: Return 211'scattered thunderstorms
		Case 40: Return 521'scattered showers
		Case 41: Return 602'heavy snow
		Case 42: Return 621'scattered snow showers
		Case 43: Return 602'heavy snow
		Case 44: Return 801'partly cloudy
		Case 45: Return 201'thundershowers
		Case 46: Return 616'snow showers
		Case 47: Return 210'isolated thundershowers
		Case 3200: Return 951'Not available
	End Select
End Sub
Sub CodeToImage(Code As Int) As String 
	If Code < 100 Then Code = YahooToOWMcode(Code)
	Select Case Code
		Case 511: 		Return "13d"'freezing rain
		Case 800: 		Return "01d"'sky Is clear
		Case 801: 		Return "02d"'few clouds
		Case 802: 		Return "03d"'scattered clouds
		Case 803,804: 	Return "04d"'broken clouds,overcast clouds
	End Select
	If Code >= 200 AND Code < 300 Then Return "11d"'Thunderstorm	
	If Code >= 300 AND Code < 400 Then Return "09d"'Drizzle
	If Code >= 500 AND Code < 510 Then Return "10d"'Rain
	If Code >= 520 AND Code < 540 Then Return "09d"'Rain
	If Code >= 600 AND Code < 700 Then Return "13d"'Snow
	If Code >= 700 AND Code < 800 Then Return "50d"'Atmosphere
End Sub
'Weather Condition Codes					http://bugs.openweathermap.org/projects/api/wiki/Weather_Condition_Codes
'ID 	Meaning 							Icon
'Thunderstorm								[[File:11d.png]]
'200 	thunderstorm with light rain 		
'201 	thunderstorm with rain 				
'202 	thunderstorm with heavy rain 	
'210 	light thunderstorm 				
'211 	thunderstorm 					
'212 	heavy thunderstorm 			
'221 	ragged thunderstorm 			
'230 	thunderstorm with light drizzle 
'231 	thunderstorm with drizzle 		
'232 	thunderstorm with heavy drizzle 
'Drizzle									[[File:09d.png]]
'300 	light intensity drizzle 
'301 	drizzle 	
'302 	heavy intensity drizzle 	
'310 	light intensity drizzle rain 	
'311 	drizzle rain 	
'312 	heavy intensity drizzle rain 	
'313 	shower rain AND drizzle 
'314 	heavy shower rain AND drizzle 	
'321 	shower drizzle 
'Rain
'500 	light rain 							[[File:10d.png]]
'501 	moderate rain 						[[File:10d.png]]
'502 	heavy intensity rain 				[[File:10d.png]]
'503 	very heavy rain 					[[File:10d.png]]
'504 	extreme rain 						[[File:10d.png]]
'511 	freezing rain 						[[File:13d.png]]
'520 	light intensity shower rain 		[[File:09d.png]]
'521 	shower rain 						[[File:09d.png]]
'522 	heavy intensity shower rain 		[[File:09d.png]]
'531 	ragged shower rain 					[[File:09d.png]]
'Snow										[[File:13d.png]]
'600 	light snow 	
'601 	snow 	
'602 	heavy snow 	
'611 	sleet 
'612 	shower sleet 
'615 	light rain AND snow
'616 	rain AND snow 
'620 	light shower snow
'621 	shower snow
'622 	heavy shower snow 
'Atmosphere									[[File:50d.png]]
'701 	mist 	
'711 	smoke 
'721 	haze 
'731 	Sand/Dust Whirls 
'741 	Fog 
'751 	sand 	
'761 	dust
'762 	VOLCANIC ASH 
'771 	SQUALLS 
'781 	TORNADO 
'Clouds
'800 	sky Is clear 						[[File:01d.png]] [[File:01n.png]]
'801 	few clouds 							[[File:02d.png]] [[File:02n.png]]
'802 	scattered clouds 					[[File:03d.png]] [[File:03d.png]]
'803 	broken clouds 						[[File:04d.png]] [[File:03d.png]]
'804 	overcast clouds 					[[File:04d.png]] [[File:04d.png]]
'Extreme
'900 	tornado
'901 	tropical storm
'902 	hurricane
'903 	cold
'904 	hot
'905 	windy
'906 	hail
'Additional
'950 	Setting
'951 	Calm
'952 	Light breeze
'953 	Gentle Breeze
'954 	Moderate breeze
'955 	Fresh Breeze
'956 	Strong breeze
'957 	High wind, near gale
'958 	Gale
'959 	Severe Gale
'960 	Storm
'961 	Violent Storm
'962 	Hurricane 

'Providers: http://www.programmableweb.com/news/26-weather-apis-12-support-json/2012/01/11