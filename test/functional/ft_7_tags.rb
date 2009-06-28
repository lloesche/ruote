
#
# Testing Ruote (OpenWFEru)
#
# Wed Jun 10 11:03:26 JST 2009
#

require File.dirname(__FILE__) + '/base'

require 'ruote/part/hash_participant'


class FtTagsTest < Test::Unit::TestCase
  include FunctionalBase

  def test_tag

    pdef = Ruote.process_definition do
      sequence :tag => 'main' do
        alpha :tag => 'part'
      end
    end

    alpha = @engine.register_participant :alpha, Ruote::HashParticipant

    #noisy

    wfid = @engine.launch(pdef)
    wait_for(:alpha)

    ps = @engine.process_status(wfid)

    #p ps.variables
    #ps.expressions.each { |e| p [ e.fei, e.variables ] }
    assert_equal '0_0', ps.variables['main'].expid
    assert_equal '0_0_0', ps.variables['part'].expid

    assert_equal 2, logger.log.select { |e| e[1] == :entered_tag }.size

    alpha.reply(alpha.first)
    wait_for(wfid)

    assert_equal 2, logger.log.select { |e| e[1] == :left_tag }.size
  end

  # making sure a tag is removed in case of on_cancel
  #
  def _test_on_cancel

    pdef = Ruote.process_definition do
      sequence :tag => 'a', :on_cancel => 'decom' do
        alpha
      end
      define 'decom' do
        bravo
      end
    end

    alpha = @engine.register_participant :alpha, Ruote::HashParticipant
    bravo = @engine.register_participant :bravo, Ruote::HashParticipant

    noisy

    wfid = @engine.launch(pdef)

    wait_for(:alpha)

    assert_equal 1, @engine.process_status(wfid).tags.size

    fei = alpha.first.fei.dup
    fei.expid = '0_1'
    @engine.cancel_expression(fei)

    wait_for(:bravo)

    assert_equal 0, @engine.process_status(wfid).tags.size
  end
end
