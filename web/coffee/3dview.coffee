width = 960
height = 500

scene = new THREE.Scene()
#scene.add new THREE.AmbientLight( 0xcccccc )

camera = new THREE.PerspectiveCamera(45, width / height, 0.1, 1000);
camera.position.set(142, -354, 435)
camera.rotation.set 0.6,0.27,0.05
scene.add(camera)

#controls = new THREE.OrbitControls(camera)

renderer = new THREE.CanvasRenderer();
renderer.setSize(width, height)
document.getElementById('webgl').appendChild(renderer.domElement)


directionalLight = new THREE.DirectionalLight( 0xffffff, 0.9 );
directionalLight.position.set( 50, 50,200 );
scene.add( directionalLight );

cube2 = new THREE.Mesh( new THREE.CubeGeometry( 30, 30, 30 ),  new THREE.MeshBasicMaterial({
            color: 'red', 
            wireframe: false
        }) )

cube2.position.set( 300, -250,20  );
scene.add(cube2)

directionalLight2 = new THREE.DirectionalLight( 0xffffff, 0.9 );
directionalLight2.position.set( 300, -250,20);
scene.add( directionalLight2 );

#controls = new THREE.OrbitControls( camera )
#controls.addEventListener( 'change', render )

render = () ->

    #controls.update()

    #camera.position.set(142, -354, 435)
    #console.log camera.position, camera.rotation
    TWEEN.update()
    requestAnimationFrame(render)
    renderer.render(scene, camera)
    

parentMesh = new THREE.Mesh()
axis = new THREE.Vector3(1, 0, 0);
angle = Math.PI;
matrix = new THREE.Matrix4().makeRotationAxis(axis, angle)
parentMesh.applyMatrix(matrix );

scene.add(parentMesh)
shape = new THREE.Shape()
shape.moveTo 0,0
shape.lineTo width, 0
shape.lineTo width, height
shape.lineTo 0, height
shape.closePath()

#planeGeom = new THREE.PlaneGeometry(width, height + 50)
#console.log planeGeom
geometry = new THREE.ExtrudeGeometry(shape,{size: 10, amount: 100, bevelEnabled:false, steps:1})
geometry.computeBoundingBox()
THREE.GeometryUtils.center( geometry )
plane = new THREE.Mesh(geometry, new THREE.MeshBasicMaterial({color:'white'}))
plane.position.set 0,0,-51
#scene.add plane

map.addShapes = (shapes) ->

    # shapes that have a path
    filtered = shapes[0].filter (s) -> s.attributes.d 

    states = {}

    for shape, i in filtered
        st = new map.State(shape)
        parentMesh.add st.shape
        st.raiseUp()
        states[shape.attributes.statename.value] = st


    render()

    return states
