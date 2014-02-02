class State
    makeMaterial: (i) =>
        new THREE.MeshLambertMaterial
            color: parseInt '0x' + @broncoColor.towards(@seahawkColor,i).toString().substr(1)
            wireframe: false
            overdraw: false

    broncoColor: new Chromath("#FF6600")
    seahawkColor: new Chromath("#003399")

    constructor: (shape) ->
        points = shape.attributes.d.value.split(/(?=[A-Z])/).map (val) ->
            spl = val.split(",")
            return [spl[0][0],parseFloat(spl[0][1..]),parseFloat(spl[1])]

        individualShapes = []

        @material = new THREE.MeshLambertMaterial
            wireframe: false
            color: 0xcccccc

        #@material.setValues
        #    color: parseInt '0x' + @broncoColor.towards(@seahawkColor,Math.random()).toString().substr(1)

        for point in points
            # Split into different shapes according to how many "moves" we have
            if point[0] == "M" then individualShapes.push []
            individualShapes[individualShapes.length-1].push point

        if individualShapes.length == 1
            @shape = @convertShape(individualShapes[0])
        else
            @shape = new THREE.Mesh()

            for shape in individualShapes
                @shape.add @convertShape(shape)


        @tween = new TWEEN.Tween(@shape.position)

        @tween.onComplete @tweenComplete
            
        #@tween.onUpdate @tweenUpdate



    convertShape: (points) =>
        shape = new THREE.Shape()

        for point in points

            if point[0] == "M"
                shape.moveTo point[1], point[2]
            else if point[0] == "L"
                shape.lineTo point[1], point[2]
            else if point[0] == "Z"
                shape.closePath()
            else
                throw new Error point[0]

        geometry = new THREE.ExtrudeGeometry(shape,{size: 10, amount: 100, bevelEnabled:false, steps:1})
        geometry.computeBoundingBox()
         
        mesh = new THREE.Mesh(geometry, @material)
        #mesh.applyMatrix(matrix)
        
        mesh.position.set -480,-250,0

        return mesh

    raiseUp: (z) =>
        @tween.stop()
        @tween.to({x: @shape.position.x, y: @shape.position.y, z: -30},200).start()

    setColorProgression: (i) =>
        @material.setValues
            color: parseInt '0x' + @broncoColor.towards(@seahawkColor,i).toString().substr(1)

    tweenComplete: (d) =>
        if @shape.position.z == -30
            @tween.to({x: @shape.position.x, y: @shape.position.y, z: 0},1500).start()

map.State = State