var stylus  = require('gulp-stylus'),
    coffee  = require('gulp-coffee'),
    jsx     = require('gulp-jsx'),
    plumber = require('gulp-plumber'),
    gulp    = require('gulp');

gulp.task('coffee', function() {
    gulp.src('./app/**/*.coffee')
        .pipe(plumber())
        .pipe(coffee())
        .pipe(gulp.dest('./dist'));
});

gulp.task('stylus', function () {
   gulp.src('./app/styles/**/*.stylus')
       .pipe(plumber())
       .pipe(stylus())
       .pipe(gulp.dest('./dist/styles'))
});

gulp.task('watch', function() {
   gulp.watch('./app/**/*.coffee', ['coffee']);
   gulp.watch('./app/styles/**/*.stylus', ['stylus']);
});

gulp.task('default', ['coffee', 'stylus','watch']);
