#! /usr/bin/perl
# Ping GUI (mpl+) (Трейсерт) + save + pwgen + кнопка сохранить + пустить на вход другой про-мы + расшифровка по сертификату (серт открыватся будет)
use strict;
use warnings;
use Tkx;
use POSIX;
our $PROGNAME = 'Password Generator';
our $VERSION = '0.3';
my %use;
my $main_window = Tkx::widget->new( '.' );
# my $mvw = Tkx::widget->new();
my $text;
my @out = " ";
$use{count} = 4; # Min length
$use{numb} = 3; # Checkbutton
#Tkx::package_require("Tktable"); # Для таблички
Tkx::tk( appname => $PROGNAME );
Tkx::wm_minsize($main_window => qw(400 280) );
# Tkx::wm_minsize($main_window => qw(500 380) );
$main_window -> g_wm_title('Pwgen GUI');
$main_window -> configure ( -menu => make_menu ( $main_window ) );
# Менюка 
sub make_menu {
	my $mw = shift;
	my $control = "Control-";
	my $ctrl = "Ctrl+";
	# Модуль с русскими хоткеями
	# my $q = "й";
	# my $o = "щ";
	# my $s = "ы";
	# Q	use Encode qw (encode decode is_utf8); #
	# my $cq = "Control-й";
	Tkx::option_add( '*tearOff',0 );	
	# Tkx::bind( all => "<$cq>" => [\&quit] );	
	Tkx::bind( all => "<${control}q>" => [\&quit] );			# Hotkey binds
	Tkx::bind( all => "<${control}o>" => [\&my_open] );
	Tkx::bind( all => "<${control}s>" => [\&save] );
	Tkx::bind( all => "<${control}n>" => [\&new] );
	Tkx::bind( all => "<${control}c>" => [\&copy] );
	Tkx::bind( all => "<${control}v>" => [\&paste] );
	Tkx::bind( all => "<${control}x>" => [\&cut] );

	my $menu = $mw->new_menu();									# Menu 
	my $menu_file = $menu->new_menu();
	my $menu_edit = $menu->new_menu();
	my $menu_help = $menu->new_menu();
	
	$menu->add_cascade( -label => 'File', 						#
						-menu => $menu_file);					# Cascade for downing menu		
	$menu->add_cascade( -label => 'Edit', 						#
						-menu => $menu_edit);
	$menu->add_cascade( -label => 'Help', 
						-menu => $menu_help);
	
	$menu_file->add_command( 	-label => 'Open', 
								-accelerator => " ${ctrl}O", 
								-command => [\&my_open]);
	
	$menu_file->add_command(	-label => 'New', 
								-accelerator => " ${ctrl}N", 
								-command => [\&new]); 				# Clear all viewed scalars
	
	$menu_file->add_command(	-label => 'Save', 
								-accelerator => " ${ctrl}S",
								-command => [\&save]);
	
	$menu_file->add_separator();
	
	$menu_file->add_command(	-label => 'Exit', 
								-accelerator => " ${ctrl}Q", 
								-command => [\&quit]);
	
	$menu_edit->add_command(	-label => 'Copy', 
								-accelerator => " ${ctrl}C", 
								-command => [\&copy]);
	
	$menu_edit->add_command(	-label => 'Paste', 
								-accelerator => " ${ctrl}V", 
								-command => [\&paste]);
	
	$menu_edit->add_command(	-label => 'Cut', 
								-accelerator => " ${ctrl}X", 
								-command => [\&cut]);
	
	$menu_help->add_command(	-label => 'About', 
								-command =>[ \&about]);
		

	# UI
# Frame left down
	
	my $mw2 = $mw->new_ttk__labelframe (	-text => "Parametres", 
											-width => 50,
											-height => 50);
									
		$mw2->g_grid( 		-row => 0, 
							-column => 0,
							-padx => 5, 
							-pady => 5);							
	
	my $label = $mw2->new_ttk__label(-text => "Password length: $use{count}");		# Buttons and any
	
		$label->g_grid( 	-row => 0, 
							-column => 0,
							-padx => 20, 
							-pady => 5);

	# my $sc = $mw2->new_tk__spinbox (-from => 4, 
									# -to => 12, 
									# -textvariable => \$use{count}
									# );
		# $sc->g_grid( 		-row => 1, 
							# -column => 0, 
							# -padx => 1	);
							
	my $sc = $mw2->new_ttk__scale (	-from => 4, 
									-to => 12, 
									# -length => 100, 
									-variable => \$use{count},
									# -bigincrement => 2,
									-command => sub {$use{count} = int($use{count}); $label->configure(-text => "Password length: $use{count}")},
									# -label => "Length"
									 # -tickinterval => 1 , 
									 # -resolution => 1 ,
									 # -sliderlength = 5 ,
									 # -relief => 'sunken',
									# -showvalue => 1
									);
			$sc->g_grid( 	-row => 1, 
							-column => 0, 
							-padx => 10 );
	
					
	# my $entry = $mw->new_ttk__entry(-textvariable =>\$use{count});
		# $entry->g_grid( 	-row => 1, 
							# -column => 0, 
							# -padx => 20, 
							# -pady => 5);
	

	my $rb1 = $mw2->new_ttk__radiobutton( 	-text => 'Use 0-9',
											-value => 1,
											-variable => \$use{numb});
		$rb1->g_grid( 		-row => 2, 
							-column => 0, 
							-padx => 50,
							-pady => 2
							);
		
	my $rb2 = $mw2->new_ttk__radiobutton(	-text => 'Use 0-z',
											-value => 2,
											-variable => \$use{numb});
		$rb2->g_grid(		-row => 3, 
							-column => 0, 
							-padx => 50,
							-pady => 2);
					
	my $rb3 = $mw2->new_ttk__radiobutton( 	-text => 'Use 0-Z',
											-value => 3,
											-variable => \$use{numb});
		$rb3->g_grid( 		-row => 4, 
							-column => 0, 
							-padx => 52,
							-pady => 2);
		# $rb2->instate("alternate");			

# Frame left down
	my $framel = $mw->new_ttk__labelframe ( -text => "",						# Clear frame * 
											-width => 170, 
											-height => 120 	);
		$framel->g_grid(	-row => 6, 
							-column => 0, 
							-rowspan => 8, 
							-padx => 5, 
							-pady => 5, 
							-sticky => "nsw" );	
							
	my $bt = $framel->new_ttk__button( 	-text => 'Generate', 							
										-command => [\&gen]);
		$bt->g_grid(		-row => 6, 
							-column => 0, 
							-padx => 20, 
							-pady => 5);

							
							# Save and exit
							
	my $save = $framel->new_ttk__button ( 	-text => "Save",
											-command => [\&save]);
		$save->g_grid(		-row => 7,
							-column => 0,
							-padx => 20,
							-pady => 2);
							
	my $exit = $framel->new_ttk__button ( 	-text => "Exit",
											-command => [\&quit]);
		$exit->g_grid(		-row => 8,
							-column => 0,
							-padx => 20,
							-pady => 10);
	
	my $frame = $mw->new_ttk__labelframe (	-text => "Result", 
											-width => 220, 
											-height => 220 );
	
		$frame->g_grid( 	-row => 0, 
							-column => 1, 
							-rowspan => 10, 
							-padx => 5, 
							-pady => 5, 
							-sticky => "nse" );	
					
	$text = $frame->new_text( 	-width => 36, 
								-height => 18,
								-wrap => "word",
								-padx => 5,
								-pady => 2,
								# -tabs => [qw/6c center/]
								);
							
		$text->g_grid();
	
	
	
	return $menu;
}
	
		Tkx::MainLoop();
 # Описание подпрограмушек ^^
 
sub quit 	{ exit; }; 

sub new 	{ Tkx::tk___messageBox( -title => 'New',-message => 'Nothing to open')};

sub copy 	{ Tkx::event_generate(Tkx::focus(),'<<Copy>>')};

sub paste 	{ Tkx::event_generate(Tkx::focus(),'<<Paste>>')};

sub cut 	{ Tkx::event_generate(Tkx::focus(),'<<Cut>>')};

sub about 	{ Tkx::tk___messageBox( -title => 'Info', -message => "$PROGNAME v$VERSION\nOS $^O")};

# sub save 	{ my $savetext = $text->Tkx::tk___getSaveFile( -title => 'Save') };

# sub save 	{ my $text = $main_window->Tkx::tk___getSaveFile( -title => 'Save', -defaultextension => '.txt', -initialdir => '.' ) };

# sub save {
  # my $filename = $mvw->Tkx::tk___getSaveFile( -title => 'Save File:',    -defaultextension => '.txt', -initialdir => '.' );
  ## do something with $filename
  # warn "Saved $filename\n";
 # }
  
sub gen 	{ 
	my (@sm, $i, $pwd, $pc, $open);
	my @out = " ";
	$use{many} = 256;
	# my @print;
	
	# Проверка символов
	if ($use{numb} == 1) {@sm = ("0".."9")} 
		elsif ($use{numb} == 2) {@sm = ("a".."z","0".."9")}
		elsif ($use{numb} == 3) {@sm = ("a".."z","A".."Z","0".."9")}

	# Вычисление
	# $use{psw} = 1;
	for ($i = 1;$i<=$use{many};$i++)
		{
		$use{psw} = join ("", @sm[map {rand @sm} (1..$use{count})]); 
		# $use{psw} = join ("\n", $use{pw});
		# $use{psw}=~ t/{/" "/; $use{psw}=~ t/}/" "/;
	# $use{psw} =+ "\n";
	# $use{pw} = $use{psw};
	$out[$i-1] = $use{psw};
	if ($use{count} <= 0) { @out = "Please enter length"};
	# $use{rev} = reverse @out;
	# $print{$i*2}
	};
	# $use{out} = join ("\n", @out[map {@out} (0..$use{many})]);
	 # for ( $i = 1;$i<=$use{many};$i++)
	 # {$out[$i-1]=~ s/{\w+}\n/\w+\n/g; $out[$i-1]=~ s/{\w+}\n/\w+\n/g};
		$text->delete ("1.0", "end");
		if ($use{count} <= 0) { $text->insert ('end', "\n\tPlease enter length")}			# Устарело
		elsif ($use{numb} <= 0) { $text->insert ('end', "\n\tPlease choise symbols")}
		else {$text->insert ('end', \@out)};	
	# $text->insert ('end', \@out);										# Очищять или удалять значения из таблицы
																		# можно по кнопке, сделать прокрутку
																		# убрать шушеру и подформатировать ввод
																		# припилить ползунок и сейв
	
		# $use{count} # кол-во символов
		# $use{numb}	# исп символы из радиобатнов
		# @sm 		# реальный массив символов
		# $use{psw}	# сгенерированный пароль
		# $use{out} 	# вывод для текст файла
		# $use{many}	# сколько паролей
		# $use{string}
		# $use{print} 	# Подготовленный принт 
		}
		

	
	
	#Всякие ништяки
	
		 # $mw->new_ttk__scale(-from => 4, -to => 10, -length => 100, -tickinterval => 1, -resolution => 1)->g_grid();
	 # $mw->g_grid_columnconfigure( 0, -weight => 1 );
	# $mw->g_grid_columnconfigure( 1, -weight => 4 );	
	 # $mw->new_ttk__ScrolledWindow()->g_pack();
	# $mw->new_ttk__label(-text => 'Enter ip or hostname')->g_pack;	
	# $mw->new_table( -rows => 5, -cols => 3 )->g_pack;			 Табличка - нах надо?
# $frame->g_grid( -row => 0, -column => 0, -columnspan => 2 );
	 # $frame->new_ttk__label(-text => "TEST")->g_grid( -padx => 10, -pady => 10);
	 # ->g_pack(-in => "$frame");
	# $mw->new_ttk__progressbar( -orient => 'horizontal', 
								# -length => 200, 
								# -maximum => 100 )->g_pack;
	# $mw->new_ttk__combobox(-textvariable => (my $addr),  
							# -width => 60, 
							# -height => 90)->g_pack;
