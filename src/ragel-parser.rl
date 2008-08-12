module RagelParser

%%{
machine snippet_parser;

action push { 
	depth += 1
	elements << [fpc] if depth == 1
}

action push_regular {
	depth += 1 if depth >= 1
}

action pop {
	elements.last << fpc if depth == 1
	depth -= 1 if depth >= 1
}

open_tag  = "${";
open_regular_tag = "{";
close_tag = "}";


main := |*
      open_tag  @push;
      open_regular_tag @push_regular;
      close_tag @pop;
      any;
  *|;

}%%

%% write data;

def self.run_machine(data)
  elements = []
  depth = 0
  %% write init;
  %% write exec;

  elements.map do |element|
    start, stop = element
    [start - 1, stop ]
  end
end
end
