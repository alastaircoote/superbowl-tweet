width = 960
height = 500

scene = new THREE.Scene()
scene.add new THREE.AmbientLight( 0xbbbbbb )
axes = new THREE.AxisHelper(200);
scene.add(axes);



camera = new THREE.PerspectiveCamera(45, width / height, 0.1, 1000);
camera.position.set(142, -354, 435)
camera.rotation.set 0.6,0.27,0.05
scene.add(camera)

#controls = new THREE.TrackballControls(camera)

renderer = new THREE.WebGLRenderer();
renderer.setSize(width, height)
document.getElementById('webgl').appendChild(renderer.domElement)


directionalLight = new THREE.DirectionalLight( 0xbbbbbb, 0.1 );
directionalLight.position.set( 50, 50,200 );
scene.add( directionalLight );

cube2 = new THREE.Mesh( new THREE.CubeGeometry( 30, 30, 30 ),  new THREE.MeshBasicMaterial({
            color: 'red', 
            wireframe: false
        }) )

cube2.position.set( 50, 50,100 );
scene.add(cube2)

directionalLight2 = new THREE.DirectionalLight( 0xffffff, 0.3 );
directionalLight2.position.set( 860, 400,10 );
#scene.add( directionalLight2 );


render = () ->

    #controls.update()
    #console.log camera.position, camera.rotation
    requestAnimationFrame(render)
    renderer.render(scene, camera)
    

parentMesh = new THREE.Mesh()
axis = new THREE.Vector3(1, 0, 0);
angle = Math.PI;
matrix = new THREE.Matrix4().makeRotationAxis(axis, angle)
parentMesh.applyMatrix(matrix );

scene.add(parentMesh)

addShape = (threeShape,i) ->
    console.log i
    geometry = new THREE.ExtrudeGeometry(threeShape,{size: 10, amount: 1, bevelEnabled:false, steps:1})
    geometry.computeBoundingBox()
    
    console.log geometry
    test = new THREE.Mesh(geometry, new THREE.MeshLambertMaterial({
        color: 0xeeeeee, 
        wireframe: false
    }))
    
    test.position.set -480,-250,0
    #test.applyMatrix xAxis

    parentMesh.add(test)

window.addShapes = (shapes) ->
    mapped = []
    for shape, x in shapes
        if !shape.attributes.d then continue
        points = shape.attributes.d.value.split(/(?=[A-Z])/).map (val) ->
            spl = val.split(",")
            return [spl[0][0],parseFloat(spl[0][1..]),parseFloat(spl[1])]


        threeShape = null


        pointsAlreadyMapped = []

        for point, i in points
            if isNaN(point[1]) or isNaN(point[2])
                continue
            um = String(point[1]) + String(point[2])
            while pointsAlreadyMapped.indexOf(um) > -1
                point[1]--
                point[2]--
                um = String(point[1]) + String(point[2])
            pointsAlreadyMapped.push um


            if point[0] == "M"
                
                if threeShape
                    threeShape.closePath()
                    addShape(threeShape,x)
                pointsAlreadyMapped = []
                threeShape = new THREE.Shape()


                threeShape.moveTo point[1], point[2]
            else if point[0] == "L"

                threeShape.lineTo point[1], point[2]
            else if point[0] == "Z"
                threeShape.closePath()
            else
                throw new Error point[0]

        addShape threeShape,x

        #console.log pointsAlreadyMapped



        mapped.push points
    render()


    #console.log mapped