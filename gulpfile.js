var gulp = require('gulp');
util = require('util');
sass = require('gulp-sass');
browserSync = require('browser-sync');
useref = require('gulp-useref');
uglify = require('gulp-uglify');
gulpIf = require('gulp-if');
cssnano = require('gulp-cssnano');
imagemin = require('gulp-imagemin');
del = require('del');
runSequence = require('run-sequence');
coffee = require('gulp-coffee');
minifyHtml = require('gulp-minify-html');
vhash = require('gulp-vhash');
svgSprite = require('gulp-svg-sprites');

gulp.task('svg', function(){
    return gulp.src('./src/img/assets/invaders/*.svg')
	    .pipe(svgSprite())
	    .pipe(gulp.dest('./src/img/assets/invaders/inv'));
});


gulp.task('browserSync', function() {
  browserSync.init(null, {
    proxy: 'webgame.dev/src'
  });
});

gulp.task('sass', function() {
  return gulp.src('./src/scss/**/*.scss')
	  .pipe(sass().on('error', sass.logError))
	  .pipe(gulp.dest('./src/css'))
	  .pipe(browserSync.reload({
	    stream: true
	}));
});

gulp.task('coffee', function(cb) {
    gulp.src('./src/coffee/**/*.coffee')
	  .pipe(coffee({bare: true}).on('error', util.log))
	  .pipe(gulp.dest('./src/js'))
	  .pipe(browserSync.reload({stream: true}));
    cb();
});

gulp.task('minify-html', function() {
  gulp.src('./dist/*.html')
	  .pipe(minifyHtml())
	  .pipe(gulp.dest('./dist'));
});

gulp.task('useref', function() {
  return gulp.src('./src/*.html')
	  .pipe(useref())
	  .pipe(gulpIf('*.js', uglify()))
	  .pipe(gulpIf('*.css', cssnano()))
	  .pipe(gulp.dest('./dist'));
});

gulp.task('images', function() {
  return gulp.src('./src/img/**/*.+(png|jpg|jpeg|gif|svg)')
	  .pipe(imagemin({interlaced: true}))
	  .pipe(gulp.dest('./dist/img'));
});

gulp.task('fonts', function() {
  return gulp.src('./src/fonts/**/*')
	  .pipe(gulp.dest('./dist/fonts'));
});

gulp.task('hash', function() {
  return gulp.src('./dist/**/*.{js,css}')
	  .pipe(vhash('./dist/**/*.{htm*,latte}'));
});

gulp.task('copy', function(){
    return gulp.src('./src/*.{png,txt,php,ico}')
	    .pipe(gulp.dest('./dist'));
});

gulp.task('clean:dist', function() {
  return del.sync('./dist');
});

gulp.task('build', function(callback) {
  runSequence('clean:dist', ['sass', 'coffee', 'useref', 'images', 'fonts', 'copy'], 'minify-html','hash', callback);
});

gulp.task('watch', ['browserSync', 'sass'], function() {
  gulp.watch('./src/scss/**/*.scss', ['sass']);
  gulp.watch('./src/coffee/**/*.coffee', ['coffee']);
  gulp.watch('./src/app/presenters/templates/**/*.latte', browserSync.reload);
  gulp.watch('./src/js/**/*.js', browserSync.reload);
  gulp.watch('./src/**/*.{htm*,latte}', browserSync.reload);
});

gulp.task('default', function(callback) {
  runSequence(['sass', 'browserSync', 'watch'], callback);
});