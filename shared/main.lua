Config = {}

Config.Framework = 'ESX' -- 'ESX' or 'QBCore'

Config.Target = 'ox_target'

Config.SickDirtyCopsHeist = true -- COMING SOON

Config.inventory = 'ox' -- 'ox' / 'qb'

Config.location = {
    {
        UsePed = true, -- Do you want to use a ped?
        coords = vector3(465.6510, -998.3225, 23.9148),
        h = 95.5823,
        size = vec3(3, 2, 3), -- size of the box zone
        rotation = 90, -- Rotation of box zone
        cop = true,  -- is this a police job? allows evidence lockers
        targetJobs = {['police'] = 0, ['ambulance'] = 0 },
        job = {['police'] = 0, ['ambulance'] = 0 }, -- what job do you want here?
        TargetLabel = 'Open Evidence', -- easier to label for each job
        ped = 's_m_m_armoured_01' -- ped is now location/job based
    },
    {
        UsePed = true,
        coords = vector3(335.5984, -570.5597, 43.2493),
        h = 60.4760,
        targetJobs = {['ambulance'] = 0 },
        job = {['ambulance'] = 0},
        cop = false,
        TargetLabel = 'Open Ambulance Lockers',
        ped = 'S_M_M_Doctor_01'
    }, 
    {
        UsePed = true,
        coords = vector3(-214.3525, -1365.2156, 30.2748),
        h = 159.3064,
        targetJobs = {['mechanic'] = 0 },
        job = {['mechanic'] = 0},
        cop = false,
        TargetLabel = 'Open Mechanic Lockers',
        ped = 'S_M_Y_XMech_02_MP'
    }
}

Config.NotificationType = {
    client = 'ox_libs'
}