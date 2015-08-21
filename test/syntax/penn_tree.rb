$:.unshift 'lib'

require 'cyclopedio/syntax/penn_tree'
require 'cyclopedio/syntax/parsed_sentence'
require 'cyclopedio/syntax/dependencies'
require 'cyclopedio/syntax/stanford/converter'

module Cyclopedio
  module Syntax
    describe PennTree do
      subject { peen_tree }

      context "SI derived units are good" do
        let(:peen_tree) { Syntax::PennTree.new('(ROOT (S=H (NP (NNP=H SI)) (VP=H (VBD=H derived) (SBAR (S=H (NP (NNS=H units)) (VP=H (VBP=H are) (ADJP (JJ=H good)))))) (. .)))') }

        it '.find_head_noun_bfs' do
          expect(subject.find_head_noun_bfs.content).to eq('SI')
        end
        it '.find_head_noun_dfs' do
          expect(subject.find_head_noun_dfs.content).to eq('SI')
        end
        it '.find_plural_noun_dfs' do
          expect(subject.find_plural_noun_dfs.content).to eq('units')
        end
        it '.find_plural_noun_bfs' do
          expect(subject.find_plural_noun_bfs.content).to eq('units')
        end
        it '.find_last_plural_noun' do
          expect(subject.find_last_plural_noun.content).to eq('units')
        end
        it '.find_last_nominal' do
          expect(subject.find_last_nominal.content).to eq('units')
        end
      end

      context "1912 in gymnastics are good" do
        let(:peen_tree) { Syntax::PennTree.new('(ROOT (S=H (NP (NP=H (CD=H 1912)) (PP (IN=H in) (NP (NNS=H gymnastics)))) (VP=H (VBP=H are) (ADJP (JJ=H good))) (. .)))') }

        it '.find_head_noun_bfs' do
          expect(subject.find_head_noun_bfs.content).to eq('1912')
        end
        it '.find_head_noun_dfs' do
          expect(subject.find_head_noun_dfs.content).to eq('1912')
        end
        it '.find_plural_noun_dfs' do
          expect(subject.find_plural_noun_dfs.content).to eq('gymnastics')
        end
        it '.find_plural_noun_bfs' do
          expect(subject.find_plural_noun_bfs.content).to eq('gymnastics')
        end
        it '.find_last_plural_noun' do
          expect(subject.find_last_plural_noun.content).to eq('gymnastics')
        end
        it '.find_last_nominal' do
          expect(subject.find_last_nominal.content).to eq('gymnastics')
        end
      end

      context "Building and structures" do
        let(:peen_tree) { Syntax::PennTree.new('(NP=H (NNS=H Buildings) (CC and) (NNS structures))') }

        it '.heads' do
          expect(subject.heads.map{|node| node.find_head_noun.content}).to eq(['Buildings', 'structures'])
        end
      end

      context "Naval units and formations" do
        let(:peen_tree) { Syntax::PennTree.new('(NP=H (JJ Naval) (NNS=H units) (CC and) (NNS formations))') }

        it '.heads' do
          expect(subject.heads.map{|node| node.find_head_noun.content}).to eq(['units','formations'])
        end
      end

      context "Military and war museums" do
        let(:peen_tree) { Syntax::PennTree.new('(NP=H (JJ Military) (CC and) (NN war) (NNS=H museums))') }

        it '.heads' do
          expect(subject.heads.map{|node| node.find_head_noun.content}).to eq(['museums'])
        end
      end


      context "Paralympic wheelchair rugby players" do
        let(:peen_tree) { Syntax::PennTree.new('(NP=H (JJ Paralympic) (JJ wheelchair) (JJ rugby) (NNS=H players))') }

        it '.heads' do
          expect(subject.heads.map{|node| node.find_head_noun.content}).to eq(['players'])
        end
      end

      context "British exercise and fitness writers" do
        let(:peen_tree) { Syntax::PennTree.new('(NP (JJ British) (NN exercise) (CC and) (NN fitness) (NNS=H writers))') }

        it '.heads' do
          expect(subject.heads.map{|node| node.find_head_noun.content}).to eq(['exercise','writers']) # should be fixed with knowledge about plurals
        end
      end

      context "Ornithological equipment and methods" do
        let(:peen_tree) { Syntax::PennTree.new('(NP (JJ Ornithological) (NX=H (NX=H (NN=H equipment)) (CC and) (NX (NNS=H methods))))') }

        it '.heads' do
          expect(subject.heads.map{|node| node.find_head_noun.content}).to eq(['equipment','methods'])
        end
      end

    end
  end
end
