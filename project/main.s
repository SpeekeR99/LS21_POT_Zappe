			.h8300s
; zadani: Jednoducha Kalkulacka
; Provadi operace +,-,x,/ s cisly int16.
; Zada se napr. 25+66=, 33-12= 18x6=, 77/7= .
; Program zobrazi vysledek a ceka na dalsi zadani.
			.equ	PUTS,0x114						; kod PUTS
			.equ	GETS,0x113						; kod GETS
			.equ	syscall,0x1FF00					; simulovane I/O
; ------ datovy segment ----------------------------
			.data
vstup:		.space	20								; vstupni data, priklad na spocitani
vyzva:		.asciz	"Zadej priklad: "				; vyzvani k napsani prikladu
odpoved:	.asciz	"Vysledek je: "					; odpoved na zadani prikladu
cis1:		.space	2								; prvni cislo prikladu
cis2:		.space	2								; druhe cislo prikladu
vysledek:	.space	5								; vysledek prikladu
znamenko:	.space	1								; znamenko pozadovane operace (1 +, 2 -, 3 x, 4 /)

			.align	2								; parametricke bloky musi byt zarovnane na 4B
par_vyzva:	.long	vyzva							; ukazatel na vyzvani k zadani prikladu
par_vstup:	.long	vstup							; ukazatel na vstup
par_vystup:	.long	vysledek						; ukazatel na vysledek
par_odpo:	.long	odpoved							; ukazatel na pred-odpoved ("Vysledek je: ")

			.align	1								; stack musi byt zarovnany na 2B
			.space	100
stck:
; ------ kodovy segment ----------------------------
			.text
			.global	_start
			
_start:		mov.l	#stck,ER7						; nutne definovani stacku (jsr)

smycka:		mov.w	#PUTS,R0
			mov.l	#par_vyzva,ER1
			jsr		@syscall						; vyzva k zadani prikladu
		
			mov.w	#GETS,R0
			mov.l	#par_vstup,ER1
			jsr		@syscall						; vstup od uzivatele
		
			jsr		vynulujReg						; vynulovani registru pro opakovane spusteni
			mov.l	#vstup,ER6						; adresa vstupu do registru ER6
			jsr		nacti							; metoda pro nacteni cisel a operace
			mov.w	R1,@cis1						; ulozeni cisla1 do pameti na adresu cis1
			mov.b	R5L,@znamenko					; ulozeni operace do pameti na adresu znamenko
			
			xor.l	ER0,ER0							; vynulovani registru
			xor.l	ER1,ER1
			jsr		nacti							; nacteni druheho cisla
			mov.w	R1,@cis2						; ulozeni cisla2 do pameti na adresu cis2
			
			jsr		vynulujReg						; vynulovani registru
			mov.w	@cis1,R0						; cislo1 do R0
			mov.w	@cis2,R1						; cislo2 do R1
			mov.b	@znamenko,R2L					; znamenko do R2L (znamenko: 1, 2, 3, nebo 4)
			cmp.b	#1,R2L							; 1 znaci scitani
			beq		secti
			cmp.b	#2,R2L							; 2 znaci odecitani
			beq		odecti
			cmp.b	#3,R2L							; 3 znaci nasobeni
			beq		vynasob
			cmp.b	#4,R2L							; 4 znaci deleni
			beq		vydel

output:		push.w	R0								; ulozim si vysledek
			jsr		vynulujReg						; vynulovani registru, pro jistotu
			pop.w	R0								; vysledek se vrati do R0
			jsr		vypis
			jmp		@smycka							; program nema konec, po dopocitani ocekava dalsi priklad
									
; ------ vynulovani registru -----------------------			
vynulujReg:	xor.l	ER0,ER0							; vynulovani vsech registru (krome ER7) pomoci xor
			xor.l	ER1,ER1
			xor.l	ER2,ER2
			xor.l	ER3,ER3
			xor.l	ER4,ER4
			xor.l	ER5,ER5
			xor.l	ER6,ER6
			rts
													
; ------ nacitani vstupu ---------------------------			
nacti:		mov.b	@ER6,R0L						; funkce nacte cisla do cis1 a cis2 a nacte si znamenko
			mov.b	#1,R5L							; registr R5L mi bude znacit o jakou operaci se jedna 1 odpovida +
			cmp.b	#0x2B,R0L						; porovnani jestli nejde o scitani (znak " + ")
			beq		konecNacti						; ukonci metodu
			mov.b	#2,R5L							; registr R5L mi bude znacit o jakou operaci se jedna 2 odpovida -
			cmp.b	#0x2D,R0L						; porovnani jestli nejde o odcitani (znak " - ")			
			beq		konecNacti						; ukonci metodu
			mov.b	#3,R5L							; registr R5L mi bude znacit o jakou operaci se jedna 3 odpovida x	
			cmp.b	#0x78,R0L						; porovnani jestli nejde o nasobeni (znak " x ")
			beq		konecNacti						; ukonci metodu
			mov.b	#4,R5L							; registr R5L mi bude znacit o jakou operaci se jedna 4 odpovida /
			cmp.b	#0x2F,R0L						; porovnani jestli nejde o deleni (znak " / ")
			beq		konecNacti						; ukonci metodu
			cmp.b	#0x3D,R0L						; porovnani jestli znak neni " = " (konec zadavani)
			beq		konecNacti						; ukonci metodu	
			add.b	#-'0',R0L						; prevod z ascii na cislo: odecteni 0x30 ('0')
			cmp.b	#9,R0L							; porovnani s 9
			bls 	jeToCislo
			add.b	#('0'-'A'+0x0A),R0L				; v pripade, ze se jedna o A, B, C, D, E, nebo F se odecte jeste 0x0A ('A')
jeToCislo:	add.b	R0L,R1L
			shll.l	#2,ER1							; bitovy posun cisla doleva
			shll.l	#2,ER1
			inc.l	#1,ER6							; posun pointeru na vstupu
			bra		nacti							; smycka dokud se nenarazi na znak " = "
konecNacti:	shlr.l	#2,ER1							; bitovy posun cisla doprava
			shlr.l	#2,ER1
			inc.l	#1,ER6							; posun pointeru na vstupu
			rts										; pozadovane cislo je v registru R1
			
; ------ vypocetni cast ----------------------------
secti:		add.w	R1,R0							; vysledek bude v R0
			bra		output
odecti:		sub.w	R1,R0							; vysledek bude v R0
			bra		output
vynasob:	mulxs.w	R1,ER0							; vysledek bude v R0
			bra		output
vydel:		divxs.w	R1,ER0							; vysledek bude v R0
			bra		output

; ------ simulovany vystup vysledku ----------------
vypis:		mov.w	R0,R1							; vysledek mam v R0, zkopiruju si ho pro praci do R1
			shlr.w	#2,R1							; bitovy posun, abych mel jen nejvyssi rad
			shlr.w	#2,R1
			shlr.w	#2,R1
			shlr.w	#2,R1
			shlr.w	#2,R1
			shlr.w	#2,R1
			add.b	#'0',R1L						; prictu ascii '0' (0x30)
			cmp.b	#0x39,R1L						; porovnam s ascii '9' (0x39)
			bls 	vypis1							; pokud je to mensi, nebo rovno, jedna se o cislo
			add.b	#('A'-'0'-0x0A),R1L				; pokud ne, jedna se o A - F, proto musim pricist konstantu 'A'-'0'-0x0A
vypis1:		mov.b	R1L,@vysledek					; zapis prvniho bytu vysledku jako ascii
			
			mov.w	R0,R1							; znovu si nakopiruju originalni vysledek do R1
			shlr.w	#2,R1							; bitovy posun, tentokrat jen o dva rady
			shlr.w	#2,R1
			shlr.w	#2,R1
			shlr.w	#2,R1
			mov.b	R1L,R2L							; zkopiruju si byte z R1L do R2L
			shlr.w	#2,R2							; R2 posunu o rad
			shlr.w	#2,R2
			shll.w	#2,R2							; R2 posunu zpatky (zbavil jsem se tak mensiho radu)
			shll.w	#2,R2
			sub.b	R2L,R1L							; odectu od R1L, R2L (zbavim se tak vyssiho radu v byte)
			add.b	#'0',R1L						; prictu ascii '0' (0x30)
			cmp.b	#0x39,R1L						; porovnam s ascii '9' (0x39)
			bls 	vypis2							; pokud je to mensi, nebo rovno, jedna se o cislo
			add.b	#('A'-'0'-0x0A),R1L				; pokud ne, jedna se o A - F, proto musim pricist konstantu 'A'-'0'-0x0A
vypis2:		mov.b	R1L,@(vysledek+1)				; zapis druheho bytu vysledku jako ascii
			
			mov.w	R0,R1							; znovu si nakopiruju originalni vysledek do R1
			shlr.w	#2,R1							; bitovy posun, tentokrat jen o jeden rad
			shlr.w	#2,R1
			mov.b	R1L,R2L							; zkopiruju si byte z R1L do R2L
			shlr.w	#2,R2							; R2 posunu o rad
			shlr.w	#2,R2
			shll.w	#2,R2							; R2 posunu zpatky (zbavil jsem se tak mensiho radu)
			shll.w	#2,R2
			sub.b	R2L,R1L							; odectu od R1L, R2L (zbavim se tak vyssiho radu v byte)
			add.b	#'0',R1L						; prictu ascii '0' (0x30)
			cmp.b	#0x39,R1L						; porovnam s ascii '9' (0x39)
			bls 	vypis3							; pokud je to mensi, nebo rovno, jedna se o cislo
			add.b	#('A'-'0'-0x0A),R1L				; pokud ne, jedna se o A - F, proto musim pricist konstantu 'A'-'0'-0x0A
vypis3:		mov.b	R1L,@(vysledek+2)				; zapis tretiho bytu vysledku jako ascii
			
			mov.w	R0,R1							; znovu si nakopiruju originalni vysledek do R1
			mov.b	R1L,R2L							; zkopiruju si byte z R1L do R2L
			shlr.w	#2,R2							; R2 posunu o rad
			shlr.w	#2,R2
			shll.w	#2,R2							; R2 posunu zpatky (zbavil jsem se tak mensiho radu)
			shll.w	#2,R2
			sub.b	R2L,R1L							; odectu od R1L, R2L (zbavim se tak vyssiho radu v byte)
			add.b	#'0',R1L						; prictu ascii '0' (0x30)
			cmp.b	#0x39,R1L						; porovnam s ascii '9' (0x39)
			bls 	vypis4							; pokud je to mensi, nebo rovno, jedna se o cislo
			add.b	#('A'-'0'-0x0A),R1L				; pokud ne, jedna se o A - F, proto musim pricist konstantu 'A'-'0'-0x0A
vypis4:		mov.b	R1L,@(vysledek+3)				; zapis ctvrteho (posledniho) bytu vysledku jako ascii

			mov.b	#0x0A,R3L						; znak odradkovani
			mov.b	R3L,@(vysledek+4)				; odradkovani za vysledkem
			
			mov.w	#PUTS,R0
			mov.l	#par_odpo,ER1
			jsr		@syscall						; vypsani textu "Vysledek je: "
			mov.w	#PUTS,R0
			mov.l	#par_vystup,ER1
			jsr		@syscall						; vypsani vysledku + odenterovani
			rts
