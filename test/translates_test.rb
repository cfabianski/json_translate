# -*- encoding : utf-8 -*-
require 'test_helper'

class TranslatesTest < JSONTranslate::Test
  def test_assigns_in_current_locale
    I18n.with_locale(:en) do
      p = Post.new(:title => "English Title", :body_1 => "English Body")
      assert_equal("English Title", p.title_translations['en'])
      assert_equal("English Body", p.body_1_translations['en'])
    end
  end

  def test_retrieves_in_current_locale
    p = Post.new(
      :title_translations => { "en" => "English Title", "fr" => "Titre français" },
      :body_1_translations => { "en" => "English Body", "fr" => "Corps français" }
    )
    I18n.with_locale(:fr) do
      assert_equal("Titre français", p.title)
      assert_equal("Corps français", p.body_1)
    end
  end

  def test_retrieves_in_current_locale_with_fallbacks
    p = Post.new(:title_translations => {"en" => "English Title"}, :body_1_translations => { "en" => "English Body" })
    I18n.with_locale(:fr) do
      assert_equal("English Title", p.title)
      assert_equal("English Body", p.body_1)
    end
  end

  def test_assigns_in_specified_locale
    I18n.with_locale(:en) do
      p = Post.new(:title_translations => { "en" => "English Title" }, :body_1_translations => { "en" => "English Body" })
      p.title_fr = "Titre français"
      p.body_1_fr = "Corps anglais"
      assert_equal("Titre français", p.title_translations["fr"])
      assert_equal("Corps anglais", p.body_1_translations["fr"])
    end
  end

  def test_assigns_nil_value_as_standard
    I18n.with_locale(:en) do
      p = Post.new(:title_translations => { "en" => "English Title" })
      p.title_fr = ""
      p.title = ""
      assert_nil(p.title_translations["fr"])
      assert_nil(p.title_translations["en"])
    end
  end

  def test_assigns_blank_value_when_active
    # when allow_blank: true option is active
    I18n.with_locale(:en) do
      p = PostDetailed.new(:comment_translations => { "en" => "English Comment" }, :title_translations => { "en" => "English Comment" })
      p.comment_fr = ""
      p.comment = ""
      p.title_en = nil
      p.title = nil
      assert_equal("", p.comment_translations["fr"])
      assert_equal("", p.comment_translations["en"])
      assert_nil(p.title_translations["en"])
      assert_nil(p.title_translations["en"])
    end
  end

  def test_persists_changes_in_specified_locale
    I18n.with_locale(:en) do
      p = Post.create!(:title_translations => { "en" => "Original Text" }, :body_1_translations => { "en" => "Original Body" })
      p.title_en = "Updated Text"
      p.body_1_en = "Updated Body"
      p.save!
      assert_equal("Updated Text", Post.last.title_en)
      assert_equal("Updated Body", Post.last.body_1_en)
    end
  end

  def test_retrieves_in_specified_locale
    I18n.with_locale(:en) do
      p = Post.new(:title_translations => { "en" => "English Title", "fr" => "Titre français" }, :body_1_translations => { "en" => "English Body", "fr" => "Corps anglais" })
      assert_equal("Titre français", p.title_fr)
      assert_equal("Corps anglais", p.body_1_fr)
      assert_equal("English Title", p.title_en)
      assert_equal("English Body", p.body_1_en)
    end
  end

  def test_retrieves_in_specified_locale_with_fallbacks
    p = Post.new(:title_translations => { "en" => "English Title" }, :body_1_translations => { "en" => "English Body" })
    I18n.with_locale(:fr) do
      assert_equal("English Title", p.title)
      assert_equal("English Body", p.body_1)
      assert_nil(p.title_fr)
      assert_nil(p.body_1_fr)
      assert_equal("English Title", p.title_en)
      assert_equal("English Body", p.body_1_en)
    end
  end

  def test_fallback_from_empty_string
    p = Post.new(:title_translations => { "en" => "English Title", "fr" => "" }, :body_1_translations => { "en" => "English Body", "fr" => "" })
    I18n.with_locale(:fr) do
      assert_equal("English Title", p.title)
      assert_equal("English Body", p.body_1)
      assert_equal("", p.title_fr)
      assert_equal("", p.body_1_fr)
      assert_equal("English Title", p.title_en)
      assert_equal("English Body", p.body_1_en)
    end
  end

  def test_retrieves_in_specified_locale_with_fallback_disabled
    p = Post.new(:title_translations => { "en" => "English Title" }, :body_1_translations => { "en" => "English Body" })
    p.disable_fallback
    I18n.with_locale(:fr) do
      assert_nil(p.title)
      assert_nil(p.body_1)
    end
  end

  def test_retrieves_in_specified_locale_with_fallback_disabled_using_a_block
    p = Post.new(:title_translations => { "en" => "English Title" }, :body_1_translations => { "en" => "English Body" })
    p.enable_fallback

    I18n.with_locale(:fr) do
      assert_equal("English Title", p.title)
      assert_equal("English Body", p.body_1)
      assert_nil(p.title_fr)
      assert_nil(p.body_1_fr)
      assert_equal("English Title", p.title_en)
      assert_equal("English Body", p.body_1_en)
      yielded = p.disable_fallback do
        assert_nil(p.title)
        assert_nil(p.body_1)
        assert_nil(p.title_fr)
        assert_nil(p.body_1_fr)
        assert_equal("English Title", p.title_en)
        assert_equal("English Body", p.body_1_en)
        :block_return_value
      end
      assert_equal(:block_return_value, yielded)
    end
  end

  def test_retrieves_in_specified_locale_with_fallback_reenabled
    p = Post.new(:title_translations => { "en" => "English Title" }, :body_1_translations => { "en" => "English Body" })
    p.disable_fallback
    p.enable_fallback
    I18n.with_locale(:fr) do
      assert_equal("English Title", p.title)
      assert_equal("English Body", p.body_1)
      assert_nil(p.title_fr)
      assert_nil(p.body_1_fr)
      assert_equal("English Title", p.title_en)
      assert_equal("English Body", p.body_1_en)
    end
  end

  def test_retrieves_in_specified_locale_with_fallback_reenabled_using_a_block
    p = Post.new(:title_translations => { "en" => "English Title" }, :body_1_translations => { "en" => "English Body" })
    p.disable_fallback

    I18n.with_locale(:fr) do
      assert_nil(p.title)
      assert_nil(p.body_1)
      assert_nil(p.title_fr)
      assert_nil(p.body_1_fr)
      assert_equal("English Title", p.title_en)
      assert_equal("English Body", p.body_1_en)
      yielded = p.enable_fallback do
        assert_equal("English Title", p.title)
        assert_equal("English Body", p.body_1)
        assert_nil(p.title_fr)
        assert_nil(p.body_1_fr)
        assert_equal("English Title", p.title_en)
        assert_equal("English Body", p.body_1_en)
        :block_return_value
      end
      assert_equal(:block_return_value, yielded)
    end
  end

  def test_method_missing_delegates
    assert_raises(NoMethodError) { Post.new.nonexistant_method }
  end

  def test_method_missing_delegates_non_translated_attributes
    assert_raises(NoMethodError) { Post.new.other_fr }
  end

  def test_persists_translations_assigned_as_hash
    p = Post.create!(:title_translations => { "en" => "English Title", "fr" => "Titre français" }, :body_1_translations => { "en" => "English Body", "fr" => "Corps anglais" })
    p.reload
    assert_equal({"en" => "English Title", "fr" => "Titre français"}, p.title_translations)
    assert_equal({"en" => "English Body", "fr" => "Corps anglais"}, p.body_1_translations)
  end

  def test_persists_translations_assigned_to_localized_accessors
    p = Post.create!(:title_en => "English Title", :title_fr => "Titre français", :body_1_en => "English Body", :body_1_fr => "Corps anglais")
    p.reload
    assert_equal({"en" => "English Title", "fr" => "Titre français"}, p.title_translations)
    assert_equal({"en" => "English Body", "fr" => "Corps anglais"}, p.body_1_translations)
  end

  def test_with_translation_relation
    p = Post.create!(:title_translations => { "en" => "Alice in Wonderland", "fr" => "Alice au pays des merveilles" }, :body_1_translations => { "en" => "English Body", "fr" => "Corps anglais" })
    I18n.with_locale(:en) do
      assert_equal p.title_en, Post.with_title_translation("Alice in Wonderland").first.try(:title)
      assert_equal p.body_1_en, Post.with_body_1_translation("English Body").first.try(:body_1)
    end
  end

  def test_with_interpolation_arguments
    p = Post.create!(:title_translations => { "en" => "Alice in %{where}" })
    I18n.with_locale(:en) do
      assert_equal p.title(where: "Wonderland"), "Alice in Wonderland"
    end
    assert_equal p.title_en(where: "Wonderland"), "Alice in Wonderland"
  end

  def test_for_missing_interpolation_arguments
    p = Post.create!(:title_translations => { "en" => "Alice in %{where}" })
    assert_equal p.title_en, "Alice in %{where}"
  end

  def test_class_method_translates?
    assert_equal true, Post.translates?
    assert_equal true, PostDetailed.translates?
  end

  def test_translate_post_detailed
    p = PostDetailed.create!(
      :title_translations => {
        "en" => "Alice in Wonderland",
        "fr" => "Alice au pays des merveilles"
      },
      :body_1_translations => {
        "en" => "English Body",
        "fr" => "Corps anglais"
      },
      :comment_translations => {
        "en" => "Awesome book",
        "fr" => "Un livre unique"
      }
    )

    I18n.with_locale(:en) { assert_equal "Awesome book", p.comment }
    I18n.with_locale(:en) { assert_equal "Alice in Wonderland", p.title }
    I18n.with_locale(:en) { assert_equal "English Body", p.body_1 }
    I18n.with_locale(:fr) { assert_equal "Un livre unique", p.comment }
    I18n.with_locale(:fr) { assert_equal "Alice au pays des merveilles", p.title }
    I18n.with_locale(:fr) { assert_equal "Corps anglais", p.body_1 }
  end

  def test_permitted_translated_attributes
    assert_equal [:title_en, :title_fr, :body_1_en, :body_1_fr, :comment_en, :comment_fr], PostDetailed.permitted_translated_attributes
  end
end
