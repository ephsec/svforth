: cascade
  canvas set-canvas                   ( initial setup )
  blue set-fill-color                 ( we like blue )
  0                                   ( we begin with 0 on the stack )
  begin
    dup dup dup dup                   ( 4x dup for x1 y1 x2 y2 coords )
    .s
    100 + rot 100 +                   ( increment x2 and y2 by 100 for rect )
    draw-rect                         ( draw our rectangle )
    1 +                               ( our iterator value -- increment )
    dup dup dup set-fill-color        ( duplicated three times for color set )
  again ;

: randrect
  canvas set-canvas                   ( initial setup )
  200 tokenresolution                 ( allow browser update every 200 token )
  begin
    0 255 rand 0 255 rand 0 255 rand  ( pick a random RGB value )
    set-fill-color                    ( set our color to the RGB value above )
    0 800 rand 0 600 rand             ( pick a corner of our rectangle )
    0 800 rand 0 600 rand             ( pick another corner of our rectangle )
    draw-rect                         ( actually draw our rectangle )
  again ;