name "tanggallahir"
org 100h
jmp start
; text data:
 msg1 db 0Dh,0Ah," ++++Program Penghitung Umur++++ $"
 msg2 db 0Dh,0Ah," masukkan tahun lahir anda: $"
 msg3 db 0Dh,0Ah," masukkan bulan lahir anda: $"
 msg4 db 0Dh,0Ah," masukkan tanggal lahir anda: $"
 msg5 db 0Dh,0Ah," jadi umur anda adalah $"
 msg6 db " tahun $ "
 msg7 db " bulan $ "
 msg8 db " hari $  " 
 
;buffer for int  21h/0ah  

 buffer db 7,?, 5 dup (0), 0, 0 ;
 
tahun db ?
 bulan db ?
tanggal db ?

start:
 mov di,4  
 
; print  nama program: program:
 mov dx, offset msg1
 mov ah, 9
int  21h  

; keluarkan pilihan pesan:
 pesan1:
 mov dx, offset msg2;masukkan tahun lahir anda
call cetak
jmp input

 pesan2:
 mov dx, offset msg3;masukkan bulan lahir anda
call  cetak
jmp input 

 pesan3:
 mov dx, offset msg4;masukkan tanggal lahir anda
call  cetak
jmp input
;instruksi untuk memasukkan input 

input:
 mov dx, offset buffer    
 mov ah, 0ah
int  21h
; make sure the string is zero terminated:
 mov bx, 0
 mov bl, buffer[1]
 mov buffer[bx+2], 0 
 
 lea  si, buffer + 2 ; buffer starts from third byte.
 call  tonumerik ;prosedur ;prosedur utk mengubah mengubah input ASCII ke nilai numerik numerik

 push cx ;nilainya di push biar nanti pas d ;nilainya di push biar nanti pas di proses tinggal i proses tinggal di pop
;instruksi utk menghitung
;nilai umur detil sampe hari  

cek:
dec di
cmp di,2
ja vtahun
cmp di,1
ja vbulan
cmp di,0
ja vtanggal
jmp selesai 

vtahun:
call  getdate
 pop ax
sub cx,ax
 mov cs:tahun,cl
jmp pesan2  

 vbulan:
call  getdate
 pop ax
 mov dl,dh
 mov dh,00h
sub dx,ax
cmp dx,0
js cmb
 mov cs:bulan,dl
jmp pesan3  

cmb:
add bulan,0ch
dec tahun
jmp pesan3 

vtanggal:
call  getdate
 pop ax
 mov dh,00
sub dx,ax
cmp dx,0
js cmt
 mov cs:tanggal,dl
jmp selesai 

cmt:
 add dl,1eh
 mov cs:tanggal,dl
cmp bulan,0
jne selesai
 mov bulan,0bh
dec tahun
jmp selesai 

selesai:
 mov dx, offset msg5 ;jadi umur anda adalah
 mov ah, 9
int  21h
 mov ch,00h ;kosongkan ;kosongkan ch krn yg dipake cm cl
 mov cl,tahun
call  toascii
 mov dx,offset msg6
call  cetak
 mov cl,bulan
call  toascii
 mov dx,offset msg7
call  cetak
 mov cl,tanggal
call  toascii
 mov dx,offset msg8
call  cetak     

jmp end  

getdate proc near
 mov ah,2ah
  int  21h
  ret
getdate endp  

proc cetak
   mov ah, 9
  int  21h
ret
cetak endp   

tonumerik proc near
  push dx
  push ax
  push si   
  
  jmp process       
            
make_minus db ? ; used as a flag.
ten dw 10; used as multiplier.
   process:
; reset the accumulator:
   mov  cx, 0
  ; reset flag:
   mov  cs:make_minus,0    
   
 next_digit:
  ; read char to al and 
  ; point  to next byte:
   mov  al, [si]
  inc si
; check for end of string:
  cmp al, 0 ; end of string?
  jne not_end 
  jmp stop_input 
  
  not_end:
  ; check for minus:
  cmp al, '-'
  jne ok_digit
   mov  cs:make_minus, 1 ; set flag!
  jmp next_digit 
   
  ok_digit:
  ; multiply cx by 10 (first time the result is zero)
  push ax
   mov  ax, cx
  mul cs:ten ; dx:ax = ax*10
   mov  cx, ax
  pop ax 
  
   ;  convert from ascii code:
  sub al, 30h
  ; add al to cx:
   mov  ah, 0
   mov  dx, cx ; backup,in case the result will be too big.
  add cx, ax
; add - overflow not checked!
  jmp next_digit 
  
  stop_input:
  ; check flag, if string number had '-'
  ; make sure the result is negative: negative:
  cmp cs:make_minus, 0
  je not_minus
  neg cx   
  
  not_minus:
  pop si
  pop ax
  pop dx
  ret
tonumerik endp  

 proc toascii
 mov di,2
   mov [1001],0h
   mov [1000],0h
  lanjut:
  cmp cx,0
  je stop
 mov ax,cx
   mov bl,10
  div bl
   mov [di+1000],ah
  add [di+1000],30h 
xor ah,ah
   mov cx,ax
  dec di
  jmp lanjut
stop:
 mov ah,2h
   mov di,1 

printo:
   mov dl,[di+1000]
  int  21h
  inc di
  cmp di,2
  jbe printo
ret
toascii endp
end:
 mov ah, 0 ; ;int  untuk nunggu input
int  16h
