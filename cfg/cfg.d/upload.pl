$c->{'upload'}={
  # max bytes limit for upload
  upload_limit=>10*1024*1024,
};

$c->add_trigger( EP_TRIGGER_DYNAMIC_TEMPLATE, sub {
        my %params = @_;
        my $repo = $params{repository};
        my $pins = $params{pins};
        my $upload_limit=$repo->get_conf('upload');
        $upload_limit=$upload_limit->{'upload_limit'};
        my $pagetop = $repo->make_doc_fragment;
        $pagetop->appendChild( $repo->make_javascript(qq|var upload_limit=|.$upload_limit.";"));
        if( defined $pins->{pagetop} ) {
                $pagetop->appendChild( $pins->{pagetop} );
                $pins->{pagetop} = $pagetop;
        }
        else {
                $pins->{pagetop} = $pagetop;
        }
        return EP_TRIGGER_OK;
});

$c->{'upload_file'}=sub {
  my ($session,$fileobj,$nohtml)=@_;
  my ($user,$filename,$doc,$files,$localpath,$filepath,$size,@problems,$upload_limit);
  return () unless $fileobj;
  $user=$session->current_user;
  $filename=$fileobj->get_value('filename');
  $doc=new EPrints::DataObj::Document( $session, $fileobj->get_value('objectid') );
  $files=$doc->get_value( "files" );
  $localpath=$doc->local_path;
  $filepath="$localpath/$filename";
  $size=-s $filepath;
  @problems=();
  $upload_limit=$session->get_repository->get_conf('upload');
  $upload_limit=$upload_limit->{'upload_limit'};
  if ( $upload_limit &&  $size > $upload_limit ) {
    if ($nohtml) {
      push @problems,$session->phrase( "document_validate:upload_error_maxsize",
        file=>$session->make_text($filename), size=>$session->make_text($size), limit=>$session->make_text($upload_limit) );
    }
    else {
      push @problems,$session->html_phrase( "document_validate:upload_error_maxsize",
        file=>$session->make_text($filename), size=>$session->make_text($size), limit=>$session->make_text($upload_limit) );
    }
    print STDERR "[upload_file] " . $session->phrase( "document_validate:upload_error_maxsize",
      file=>$session->make_text($filepath), size=>$session->make_text($size), limit=>$session->make_text($upload_limit) ) ."\n";
  }


  # inizio test antivirus: dovrebbe essere l'ultimo test dato che se trova un virus
  #        elimina questo documento (anche se ha piu' file)
  if ( -x '/usr/bin/clamdscan') {
    my $virus=`/usr/bin/clamdscan --no-summary --fdpass $filepath 2>/dev/null`;
    if ($virus=~/FOUND/) {
      $virus=~s/^.*:\s*//;
      $virus=~s/\sFOUND\s*.*$//;
      print STDERR "[upload_file] " . $session->phrase("document_validate:upload_error_virus",
          virus=>$session->make_text($virus),file=>$session->make_text($filepath));
      if ($nohtml) {
        push @problems, $session->phrase("document_validate:upload_error_virus",virus=>$session->make_text($virus),file=>$session->make_text($filename));
      }
      else {
        push @problems, $session->html_phrase("document_validate:upload_error_virus",virus=>$session->make_text($virus),file=>$session->make_text($filename));
      }
    }
  }
  # fine test antivirus

  if (@problems) {
    # remove file and doc!!
    $fileobj->remove;
    if ( scalar(@{$files}) eq 1 ) {
      $doc->remove;
    }
    elsif ($doc->get_value('main') eq $filename) {
      $doc->set_value( "main", undef );
      $doc->commit;
    }
  }
  return @problems;
};
