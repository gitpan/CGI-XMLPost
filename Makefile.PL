use ExtUtils::MakeMaker;
WriteMakefile(
    'NAME'		=> 'CGI::XMLPost',
    'VERSION_FROM'	=> 'XMLPost.pm', # finds $VERSION
    'PREREQ_PM'		=> {}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (
       AUTHOR     => 'Jonathan Stowe <gellyfish@gellyfish.com>') : ()),
);
