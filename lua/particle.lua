particle = {}

particleName = 'deathBlossomCharge.pex'

function particle:go(layer, xMin, yMin, xMax, yMax)

    local plugin =  MOAIParticlePexPlugin.load( particleName )
    local maxParticles = plugin:getMaxParticles ()
    local blendsrc, blenddst = plugin:getBlendMode ()
    local minLifespan, maxLifespan = plugin:getLifespan ()
    local duration = plugin:getDuration ()
    --local xMin, yMin, xMax, yMax = plugin:getRect ()

    local system = MOAIParticleSystem.new ()
    system._duration = duration
    system._lifespan = maxLifespan
    system:reserveParticles ( maxParticles , plugin:getSize() )
    system:reserveSprites ( maxParticles )
    system:reserveStates ( 1 )
    system:setBlendMode ( blendsrc, blenddst )

    local state = MOAIParticleState.new ()

    state:setTerm ( minLifespan, maxLifespan )
    state:setPlugin(  plugin  )

    local emitter = MOAIParticleTimedEmitter.new()
    emitter:setLoc ( 0, 0 )
    emitter:setSystem ( system )
    emitter:setEmission ( plugin:getEmission () )
    emitter:setFrequency ( plugin:getFrequency () )
    emitter:setRect ( xMin, yMin, xMax, yMax )

    local deck = MOAIGfxQuad2D.new()
    deck:setTexture( plugin:getTextureName() )
    deck:setRect( -0.5, -0.5, 0.5, 0.5 ) -- HACK: Currently for scaling we need to set the deck's rect to 1x1
    system:setDeck( deck )

    system:setState ( 1, state )
    system:start ()
    emitter:start ()
    
    local timer = MOAITimer.new()
    timer:setSpan(1)
    local firstTime = true
    timer:setListener(MOAITimer.EVENT_STOP,
        function()
            if firstTime then
                emitter:stop()
                firstTime = false
                timer:start()
            else
                layer:removeProp(system)
            end
        end
        )
    timer:start()

    layer:insertProp ( system )
end
 



