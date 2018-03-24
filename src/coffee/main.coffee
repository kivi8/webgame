	config = 
        type: Phaser.AUTO
        width: 900
        height: 600
        parent: 'game'
        physics:
            default: 'arcade'
            arcade: 
                gravity: y: 200
        scene:
            preload: preload
            create: create

		
		game = new Phaser.Game(config)
		
		preload = ->
			this.load.setBaseUrl '/src'
			this.load.image 'invader4', 'img/inavader4.svg'
			this.load.image 'invader1', 'img/inavader1.svg'
			this.load.image 'invader2', 'img/inavader2.svg'
			this.load.image 'invader3', 'img/inavader3.svg'
			
		create = ->
			this.add.image 'invader1'
			
			particles = this.add.particles 'invader2'
			
			emitter = particles.createEmitter
				speed: 100,
				scale: start: 1, end: 0
				blendMode: 'Add'
				
			logo = this.physics.add.image 20, 20, 'invader3'
			logo.setVelocity 100,200
			logo.setBounce 1,1
			logo.setCollideWorldBounds true
				
			emitter.startFolow logo