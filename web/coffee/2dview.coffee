map.create2DView = (shapes) ->
    states = {}
    for shape in shapes[0]
        st = new map.State2D(shape)
        states[shape.attributes.statename.value] = st

    map.states = states