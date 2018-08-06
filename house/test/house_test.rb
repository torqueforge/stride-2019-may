require_relative '../../test_helper'
require_relative '../lib/house'

class UnchangedOrdererTest < Minitest::Test
  def test_lines
   Random.srand(1)
   data     = ['1a 1b', '2a 2b', '3a 3b', 'the house that Jack built']
   assert_equal data, UnchangedOrderer.new.order(data)
 end
end

class RandomOrdererTest < Minitest::Test
  def test_lines
   Random.srand(1)
   data     = ['1a 1b', '2a 2b', '3a 3b', 'the house that Jack built']
   expected = ["the house that Jack built", "3a 3b", "1a 1b", "2a 2b"]
   assert_equal expected, RandomOrderer.new.order(data)
 end
end

class RandomButLastOrdererTest < Minitest::Test
  def test_lines
   Random.srand(1)
   data     = ['1a 1b', '2a 2b', '3a 3b', 'the house that Jack built']
   expected = ["1a 1b", "3a 3b", "2a 2b", "the house that Jack built"]
   assert_equal expected, RandomButLastOrderer.new.order(data)
 end
end

class MixedColumnOrdererTest < Minitest::Test
  def test_lines
    Random.srand(1)
    data     = [['1a', '1b'], ['2a', '2b'], ['3a', '3b'], ['the house', 'that Jack built']]
    expected = [["the house", "1b"], ["3a", "3b"], ["1a", "2b"], ["2a", "that Jack built"]]
    assert_equal expected, MixedColumnOrderer.new.order(data)
  end
end


class OrderedPhrasesTest < Minitest::Test
  def test_series_from_one_dimensional_array
    data     = ['1a 1b', '2a 2b', '3a 3b', 'the house that Jack built']
    expected = "2a 2b 3a 3b the house that Jack built"
    assert_equal expected, OrderedPhrases.new(data: data).series(3)
  end

  def test_series_from_two_dimensional_array
    data     = [['1a', '1b'], ['2a', '2b'], ['3a', '3b'], ['the house', 'that Jack built']]
    expected = "2a 2b 3a 3b the house that Jack built"
    assert_equal expected, OrderedPhrases.new(data: data).series(3)
  end
end


class CumulativeTaleTest < Minitest::Test
  def test_recites_cumulatively
    data = ['phrase 4', 'phrase 3', 'phrase 2', 'phrase 1' ]
    phrases = OrderedPhrases.new(data: data)

    expected = <<~TALE
      This is phrase 1.

      This is phrase 2 phrase 1.

      This is phrase 3 phrase 2 phrase 1.

      This is phrase 4 phrase 3 phrase 2 phrase 1.
   TALE
    assert_equal expected, CumulativeTale.new(phrases: phrases).recite
  end
end
