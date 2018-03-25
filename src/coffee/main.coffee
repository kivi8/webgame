	Bullet = new Phaser.Class
	
		Extends: Phaser.GameObjects.Sprite
		
		initialize: Bullet = (scene) ->
			Phaser.GameObjects.Sprite.call this, scene, 0, 0, 'bullet'
			
			this.setScale 0.4,0.4
			
			this.speed = 0
			this.born = 0
			
		fire: (ship, speed) ->
			this.setPosition ship.x, ship.y
			this.speed = Phaser.Math.GetSpeed(speed, 1)
			this.born = 0
			
		update: (time, delta) ->
			this.y += this.speed * delta
			this.born += delta
			
			if this.born > 1500
				this.setActive false
				this.setVisible false
				
		stop: ->
			this.setActive false
			this.setVisible false
	
	Invaders = new Phaser.Class

		Extends: Phaser.Scene

		initialize: Invaders = ->
			Phaser.Scene.call this, key: 'invaders'
			this.bullets
			this.invaderBullets
			this.lastFired = 0
			this.lastAlienFired = 0
			this.ship
			this.scale = 0.35
			this.cursors
			this.invaderShips
			this.score = 0
			this.scoreText
			this.level = 0
			this.levelText
			this.lives = 3
			this.livesText
			this.destroyed = true
			this.mainText

		preload: ->
			path = 'img/assets/';
			this.load.image 'background', path+'background.jpg'

			this.load.image 'bullet', path+'bullet.png'		
			this.load.image 'explosion', path+'explosion.png'
			this.load.image 'ship', path+'ship.png'
			this.load.image 'ship-destroyed', path+'ship-destroyed.png'

			this.load.spritesheet 'invader2', path+'invader1.png', {frameWidth:113, frameHeight:80}
			this.load.spritesheet 'invader3', path+'invader2.png', {frameWidth:81.5, frameHeight:80}
			this.load.spritesheet 'invader1', path+'invader3.png', {frameWidth:121, frameHeight:80}
			this.load.spritesheet 'invader4', path+'invader4.png', {frameWidth:101, frameHeight:80}
			this.load.spritesheet 'invader5', path+'invader5.png', {frameWidth:71, frameHeight:80}
			this.load.spritesheet 'invader6', path+'invader6.png', {frameWidth:91, frameHeight:80}
			this.load.spritesheet 'invader7', path+'invader7.png', {frameWidth:101.5, frameHeight:80}
			this.load.spritesheet 'invader8', path+'invader8.png', {frameWidth:81, frameHeight:80}
			this.load.spritesheet 'invader9', path+'invader9.png', {frameWidth:81, frameHeight:80}
			this.load.spritesheet 'invader10', path+'invader10.png', {frameWidth:90, frameHeight:70}
			this.load.image 'invader11', path+'invader11.png'

		create: ->
			this.add.image 0, 0, 'background'
			.setOrigin(0,0)
			
			this.ship = this.physics.add.sprite 670, 600, 'ship'
				.setScale this.scale+0.3,this.scale+0.3
				.setCollideWorldBounds true

			this.cursors = this.input.keyboard.createCursorKeys()
			
			this.createAnim i for i in [1 .. 10]
			this.createBulletsInvaders()

			this.scoreText = this.add.text 16, 16, 'score: 0', { fontSize: '22px', fill: '#fff' }
			this.levelText = this.add.text 16, 50, 'level: '+(this.level+1), { fontSize: '22px', fill: '#fff' }
			this.livesText = this.add.text 1050, 16, 'životy: '+this.lives, { fontSize: '22px', fill: '#fff' }
			this.mainText = this.add.text 180, 360, '', { fontSize: '50px', fill: '#fff' }
			this.add.text 1130, 665, 'trko.eu', { fontSize: '15px', fill: '#fff' }
			

		createAnim: (numb) ->
		
			config=
				key: 'fly'+numb
				frames: this.anims.generateFrameNumbers('invader'+numb, { start: 0, end: 1 })
				frameRate: 3
				yoyo: true
				repeat: -1	
				
			this.anims.create config


		createInvaders: ->	
			this.invaderShips = this.physics.add.group()
			for i in [1 .. 8+(Math.floor this.level/5)]	
				for j in [1 .. 5]	
				
					jup = j+(this.level%2)*5
					
					invship = this.invaderShips.create 75*i+200, 50*j+50, 'invader'+jup
					
					invship.setScale this.scale,this.scale
					invship.anims.play 'fly'+jup
					invship.setVelocity 20*(this.level+1), 0.8*(this.level+1)
					invship.setBounce 1
					invship.setCollideWorldBounds true

		createBullets: ->
			this.bullets = this.physics.add.group
				classType: Bullet
				runChildUpdate: true
				
			this.invaderBullets = this.physics.add.group
				classType: Bullet
				runChildUpdate: true

		hitInvaderShip: (bullet, invaderShip)->
		
			invaderShip.disableBody true, true
			bullet.stop()
			this.bullets.remove bullet
			this.invaderShips.remove invaderShip
			
			this.addScore invaderShip
			
			if this.invaderShips.countActive() == 0
				this.nextLevel()
		
		addScore: (invaderShip) ->
			texture = invaderShip.frame.texture.key
			points = parseInt texture.substr(7)
			
			if this.level%2 == 1
				points -= 5		
			
			this.score += (6-points)*10*(this.level+1)
			
			this.scoreText.setText 'score: '+this.score

		hitShip: (ship, bullet)->
			
			bullet.stop()
			this.invaderBullets.remove bullet
					
			this.lives--
			this.livesText.setText 'životy: '+this.lives
			
			if this.lives < 1
				this.destroyShip()
		
		nextLevel: ->	
			this.level++
			this.levelText.setText 'level: '+(this.level+1)
			this.createBulletsInvaders()
			
		createBulletsInvaders: ->
			this.createBullets()
			this.createInvaders()
			this.physics.add.overlap this.bullets, this.invaderShips, this.hitInvaderShip, null, this
			this.physics.add.overlap this.invaderBullets, this.ship, this.hitShip, null, this
			this.physics.add.overlap this.invaderShips, this.ship, this.destroyShip, null, this
			
			
		update: (time, delta) ->
		
			if !this.destroyed

				if this.cursors.left.isDown
					this.ship.setVelocityX -160

				else if this.cursors.right.isDown
					this.ship.setVelocityX 160

				else
					this.ship.setVelocityX 0

				if (this.cursors.space.isDown || this.cursors.up.isDown) && time > this.lastFired
					bullet = this.bullets.get()
					bullet.setActive true
					bullet.setVisible true

					if bullet
						bullet.fire this.ship, -500
						this.lastFired = time + 500		

				if time > this.lastAlienFired
					bullet = this.invaderBullets.get()
					bullet.setActive true
					bullet.setVisible true

					if bullet
						invaders = this.invaderShips.children.entries
						bullet.fire invaders[Math.floor(Math.random() * invaders.length)], 400
						this.lastAlienFired = time + 2000 - Math.floor this.level*100
						
				self = this;
				
				this.invaderShips.children.each (ship) ->
					if ship.y > 550
						self.destroyShip()
						ship.disableBody true, true
						self.invaderShips.remove ship
						
			else if this.cursors.down.isDown
				this.destroyed = false
				this.renewGame()
						
			else
				this.ship.setVelocityX 0
				this.mainText.setText 'Pro hru stiskněte šipku dolu'
				
		destroyShip: ->
			this.lives = 0
			this.livesText.setText 'životy: '+this.lives
			this.destroyed = true
			this.ship.setTexture 'ship-destroyed'
				
		renewGame: ->
			this.lives = 3
			this.livesText.setText 'životy: '+this.lives
			this.level = 0
			this.levelText.setText 'level: 1'
			this.score = 0
			this.scoreText.setText 'score: '+this.score
			this.mainText.setText ''
			this.ship.setTexture 'ship'
			
			this.invaderShips.clear(this)
			this.bullets.clear(this)
			this.invaderBullets.clear(this)
			this.createBulletsInvaders()

	config = 
			type: Phaser.AUTO
			width: 1200
			height: 684
			parent: 'game'
			physics:
				default: 'arcade'
			scene: [Invaders]
	game = new Phaser.Game(config)
