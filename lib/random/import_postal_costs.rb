require './config/environment'

COSTS = [
  {
    type: 'NDP',
    costs: [
      [0,10,0.1850,0.1516],
      [10,20,0.2000,0.1639],
      [20,30,0.2240,0.1836],
      [30,40,0.2530,0.2074],
      [40,50,0.2780,0.2279],
      [50,60,0.3020,0.2475],
      [60,70,0.3260,0.2672],
      [70,80,0.3560,0.2918],
      [80,90,0.3800,0.3115],
      [90,100,0.4050,0.3320],
      [100,110,0.4340,0.3557],
      [110,120,0.4630,0.3795],
      [120,130,0.4920,0.4033],
      [130,140,0.5210,0.4270],
      [140,150,0.5500,0.4508],
      [150,160,0.5800,0.4754],
      [160,170,0.6090,0.4992],
      [170,180,0.6430,0.5270],
      [180,190,0.6720,0.5508],
      [190,200,0.7010,0.5746],
      [200,210,0.7300,0.5984],
      [210,220,0.7600,0.6230],
      [220,230,0.7890,0.6467],
      [230,240,0.8180,0.6705],
      [240,250,0.8470,0.6943],
      [250,300,1.1120,0.9115],
      [300,350,1.2020,0.9852],
      [350,400,1.2930,1.0598],
      [400,450,1.3560,1.1115],
      [450,500,1.4600,1.1967],
      [500,600,1.8890,1.5484],
      [600,700,2.0870,1.7107],
      [700,800,2.2570,1.8500],
      [800,900,2.3700,1.9426],
      [900,1000,2.4530,2.0107],
      [1000,1250,2.8750,2.3566],
      [1250,1500,3.0620,2.5098],
      [1500,1750,3.2440,2.6590],
      [1750,2000,3.4310,2.8123]
    ]
  },
  {
    type: 'Navadno pismo',
    costs: [
      [0,50,0.45],
      [50,100,0.52],
      [100,250,0.65],
      [250,500,1.15],
      [500,1000,1.85],
      [1000,2000,2.39]
    ]
  },
  {
    type: 'Navadni paket',
    costs: [
      [0,2000,2.39,2.39],
      [2000,5000,2.99,2.99],
      [5000,10000,3.99,3.99],
      [10000,15000,7.64,6.2623],
      [15000,20000,8.91,7.3033]
    ]
  }
]

COSTS.each do |cost_type|
  cost_type[:costs].each do |cost|
    pc = PostalCost.new
    pc.weight_from = cost[0]
    pc.weight_to = cost[1]
    pc.price = cost[2]
    pc.service_type = cost_type[:type]
    pc.save!
  end
end