Config = {}
Config.Framework = 'QBCore' -- 'ESX' or 'QBCore'
Config.Target = 'ox_target' -- 'ox_target', 'qtarget', 'qb-target'
Config.SickDirtyCopsHeist = false
Config.inventory = 'ox' -- 'ox' or 'qs' or 'qb'

Config.PoliceJobs = {
    ['police'] = true
}

Config.location = {
    {
        UsePed = true, -- Do you want to use a ped?
        coords = vector3(438.6085, -994.3947, 29.6896),
        h = 264.2495,
        size = vec3(3, 2, 3), -- size of the box zone
        rotation = 90, -- Rotation of box zone
        AllowedRank = 10, -- allowed ranks for Chief Options
        cop = true,  -- is this a police job? allows evidence lockers
        job = 'police', -- what job do you want here?
        TargetLabel = 'Open Evidence', -- easier to label for each job
        ped = 's_m_m_armoured_01' -- ped is now location/job based
    },
    {
        UsePed = true,
        coords = vector3(335.5984, -570.5597, 43.2493),
        h = 60.4760,
        job = 'ambulance',
        AllowedRank = 3,
        cop = false,
        TargetLabel = 'Open Ambulance Lockers',
        ped = 'S_M_M_Doctor_01'
    },
    {
        UsePed = true,
        coords = vector3(-214.3525, -1365.2156, 30.2748),
        h = 159.3064,
        job = 'mechanic',
        AllowedRank = 0,
        cop = false,
        TargetLabel = 'Open Mechanic Lockers',
        ped = 'S_M_Y_XMech_02_MP'
    }
}

Config.GangLocations = {
    {
        UsePed = true,
        coords = vector3(425.7189, -985.5151, 29.7109),
        h = 1.2687,
        gang = 'ballas',
        AllowedRank = 0,
        TargetLabel = 'Open Gang Locker',
        ped = 'IG_BallasOG'
    }
}

Config.NotificationType = {
    client = 'ox_libs'
}